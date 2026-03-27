#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f ./.env.shared.sink ]]; then
  # shellcheck disable=SC1091
  source ./.env.shared.sink
fi

if [[ -z "${DATABASE_URL:-}" && -n "${DATABASE_URL_BASE:-}" ]]; then
  DATABASE_URL="$DATABASE_URL_BASE"
fi

: "${DATABASE_URL:?Set DATABASE_URL or DATABASE_URL_BASE in env}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required." >&2
  exit 1
fi

# psql does not understand schemaName query param.
PSQL_DSN="$(echo "$DATABASE_URL" | sed -E 's/[?&]schemaName=[^&]*//g; s/[?&]$//')"

psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "./sql/indexer_registry.sql"

TMP_REGISTRY_JSON="$(mktemp)"
TMP_GLOBAL_SQL="$(mktemp)"
trap 'rm -f "$TMP_REGISTRY_JSON" "$TMP_GLOBAL_SQL"' EXIT

psql "$PSQL_DSN" -t -A <<'SQL' > "$TMP_REGISTRY_JSON"
SELECT COALESCE(
  json_agg(
    json_build_object(
      'chain', chain,
      'schema_name', schema_name,
      'chain_type', chain_type,
      'enabled', enabled,
      'sort_order', sort_order
    )
    ORDER BY sort_order ASC, chain ASC
  )::text,
  '[]'
)
FROM indexer.indexer_chains
WHERE enabled = TRUE;
SQL

node ./scripts/generate-indexer-global-sql.mjs "$TMP_REGISTRY_JSON" "./sql/indexer_global_views.sql" > "$TMP_GLOBAL_SQL"

psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "$TMP_GLOBAL_SQL"
psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "./sql/indexer_token_metadata.sql"

if [[ "${APPLY_GATEWAY_SQL:-1}" == "1" && -f "../packages/ws-gateway/sql/gateway.sql" ]]; then
  psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "../packages/ws-gateway/sql/gateway.sql"
fi
