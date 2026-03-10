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

psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "./sql/indexer_global_views.sql"
psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "./sql/indexer_token_metadata.sql"
