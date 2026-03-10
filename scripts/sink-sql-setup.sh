#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ./.substreams.env ]]; then
  # shellcheck disable=SC1091
  source ./.substreams.env
fi

if [[ "${SINK_ENV_MODE:-}" != "chain" && -f ./.env.sink ]]; then
  # shellcheck disable=SC1091
  source ./.env.sink
fi

: "${DATABASE_URL:?Set DATABASE_URL in environment (typically loaded by chain wrapper)}"
MANIFEST="${MANIFEST:-./substreams.yaml}"
SETUP_MANIFEST="${SETUP_MANIFEST:-$MANIFEST}"
DB_SCHEMA="${DB_SCHEMA:-}"

if [[ -z "$DB_SCHEMA" ]]; then
  DB_SCHEMA="$(echo "$DATABASE_URL" | sed -nE 's/.*[?&]schemaName=([^&]+).*/\1/p' || true)"
fi

: "${DB_SCHEMA:?Set DB_SCHEMA or include schemaName=... in DATABASE_URL}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required for setup (to execute schema.sql)." >&2
  exit 1
fi

# substreams-sink-sql understands schemaName=... in DSN, psql does not.
PSQL_DSN="$(echo "$DATABASE_URL" | sed -E 's/[?&]schemaName=[^&]*//g; s/[?&]$//')"
TMP_SQL="$(mktemp)"
trap 'rm -f "$TMP_SQL"' EXIT

{
  echo "CREATE SCHEMA IF NOT EXISTS \"$DB_SCHEMA\";"
  echo "SET search_path TO \"$DB_SCHEMA\";"
  cat "./schema.sql"
} > "$TMP_SQL"

psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "$TMP_SQL"

# Apply optional analytics/views layer in the same schema.
if [[ "${APPLY_ANALYTICS_SQL:-1}" == "1" && -f "./sql/protocol_analytics.sql" ]]; then
  TMP_ANALYTICS_SQL="$(mktemp)"
  trap 'rm -f "$TMP_SQL" "$TMP_ANALYTICS_SQL"' EXIT
  {
    echo "SET search_path TO \"$DB_SCHEMA\";"
    cat "./sql/protocol_analytics.sql"
  } > "$TMP_ANALYTICS_SQL"
  psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "$TMP_ANALYTICS_SQL"
fi

# Ensure token relationships/FKs are present for all token-bearing tables.
if [[ "${APPLY_TOKEN_RELATIONSHIPS_SQL:-1}" == "1" && -f "./sql/token_relationships.sql" ]]; then
  TMP_REL_SQL="$(mktemp)"
  trap 'rm -f "$TMP_SQL" "$TMP_ANALYTICS_SQL" "$TMP_REL_SQL"' EXIT
  {
    echo "SET search_path TO \"$DB_SCHEMA\";"
    cat "./sql/token_relationships.sql"
  } > "$TMP_REL_SQL"
  psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "$TMP_REL_SQL"
fi

# Optional per-chain USD token override for analytics.
if [[ -n "${USD_TOKEN_ADDRESS:-}" ]]; then
  psql "$PSQL_DSN" -v ON_ERROR_STOP=1 <<SQL
SET search_path TO "$DB_SCHEMA";
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('usd_token_address', '${USD_TOKEN_ADDRESS}')
ON CONFLICT ("key") DO UPDATE SET "value" = EXCLUDED."value";
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('usd_token_decimals', '${USD_TOKEN_DECIMALS:-6}')
ON CONFLICT ("key") DO UPDATE SET "value" = EXCLUDED."value";
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('launchpad_usd_decimals', '${LAUNCHPAD_USD_DECIMALS:-18}')
ON CONFLICT ("key") DO UPDATE SET "value" = EXCLUDED."value";
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('default_token_decimals', '${DEFAULT_TOKEN_DECIMALS:-18}')
ON CONFLICT ("key") DO UPDATE SET "value" = EXCLUDED."value";
INSERT INTO "cfg_indexer_config" ("key", "value")
VALUES ('default_token_supply', '${DEFAULT_TOKEN_SUPPLY:-1000000000}')
ON CONFLICT ("key") DO UPDATE SET "value" = EXCLUDED."value";
SQL
fi

# Create sink system tables (cursor/history/sink_info) in target schema.
# Some sink versions require a manifest that contains a `sink:` block.
substreams-sink-sql setup "$DATABASE_URL" "$SETUP_MANIFEST" --system-tables-only --bytes-encoding 0xhex
