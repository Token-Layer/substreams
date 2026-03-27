#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CHAIN="${1:-}"
SCHEMA_NAME="${2:-}"
CHAIN_TYPE="${3:-evm}"
SORT_ORDER="${4:-1000}"

if [[ -z "$CHAIN" || -z "$SCHEMA_NAME" ]]; then
  echo "Usage: $0 <chain> <schema_name> [evm|solana] [sort_order]" >&2
  exit 1
fi

if [[ -f ./.env.shared.sink ]]; then
  # shellcheck disable=SC1091
  source ./.env.shared.sink
fi

if [[ -z "${DATABASE_URL:-}" && -n "${DATABASE_URL_BASE:-}" ]]; then
  DATABASE_URL="$DATABASE_URL_BASE"
fi

: "${DATABASE_URL:?Set DATABASE_URL or DATABASE_URL_BASE in env}"

PSQL_DSN="$(echo "$DATABASE_URL" | sed -E 's/[?&]schemaName=[^&]*//g; s/[?&]$//')"

psql "$PSQL_DSN" -v ON_ERROR_STOP=1 -f "./sql/indexer_registry.sql"
psql "$PSQL_DSN" -v ON_ERROR_STOP=1 <<SQL
SELECT indexer.register_indexer_chain(
  '${CHAIN}',
  '${SCHEMA_NAME}',
  '${CHAIN_TYPE}',
  TRUE,
  ${SORT_ORDER},
  jsonb_build_object('registered_by', 'register-indexer-chain.sh')
);
SQL
