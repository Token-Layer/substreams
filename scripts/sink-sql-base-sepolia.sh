#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
export SINK_ENV_MODE="chain"

ACTION="${1:-live}"

if [[ -f ./.substreams.env ]]; then
  # shellcheck disable=SC1091
  source ./.substreams.env
fi

if [[ -f ./.env.shared.sink ]]; then
  # shellcheck disable=SC1091
  source ./.env.shared.sink
fi

if [[ -f ./.env.base-sepolia.sink ]]; then
  # shellcheck disable=SC1091
  source ./.env.base-sepolia.sink
fi

export MANIFEST="${MANIFEST:-./substreams-sink.yaml}"
export SETUP_MANIFEST="${SETUP_MANIFEST:-./substreams-sink.yaml}"
export SUBSTREAMS_ENDPOINT="${SUBSTREAMS_ENDPOINT:-basesepolia.substreams.pinax.network:443}"
export UNISWAP_V3_FACTORY="${UNISWAP_V3_FACTORY:-0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24}"
export OAPP_ADDRESS="${OAPP_ADDRESS:-0xf132F6224DaD58568c54780c14E1d3b97A5f672A}"
export USD_TOKEN_ADDRESS="${USD_TOKEN_ADDRESS:-0xED0E8956D5e7b04560460BE6B3811B0b31cEe8E1}"
export USD_TOKEN_DECIMALS="${USD_TOKEN_DECIMALS:-6}"
export LAUNCHPAD_USD_DECIMALS="${LAUNCHPAD_USD_DECIMALS:-18}"
export DEFAULT_TOKEN_DECIMALS="${DEFAULT_TOKEN_DECIMALS:-18}"
export DEFAULT_TOKEN_SUPPLY="${DEFAULT_TOKEN_SUPPLY:-1000000000}"
export DB_SCHEMA="${DB_SCHEMA:-indexer_evm_base_sepolia}"

if [[ -z "${DATABASE_URL:-}" && -n "${DATABASE_URL_BASE:-}" ]]; then
  if [[ "$DATABASE_URL_BASE" == *"schemaName="* ]]; then
    export DATABASE_URL="$DATABASE_URL_BASE"
  elif [[ "$DATABASE_URL_BASE" == *"?"* ]]; then
    export DATABASE_URL="${DATABASE_URL_BASE}&schemaName=${DB_SCHEMA}"
  else
    export DATABASE_URL="${DATABASE_URL_BASE}?schemaName=${DB_SCHEMA}"
  fi
fi

if [[ -z "${SUBSTREAMS_API_KEY:-}" && "$SUBSTREAMS_ENDPOINT" == *"pinax.network"* ]]; then
  export SUBSTREAMS_API_KEY="${PINAX_API_KEY:-}"
fi
if [[ -z "${SUBSTREAMS_API_TOKEN:-}" && "$SUBSTREAMS_ENDPOINT" == *"pinax.network"* ]]; then
  export SUBSTREAMS_API_TOKEN="${PINAX_API_TOKEN:-}"
fi
if [[ -z "${SUBSTREAMS_API_KEY:-}" && "$SUBSTREAMS_ENDPOINT" != *"pinax.network"* ]]; then
  export SUBSTREAMS_API_KEY="${STREAMINGFAST_API_KEY:-}"
fi
if [[ -z "${SUBSTREAMS_API_TOKEN:-}" && "$SUBSTREAMS_ENDPOINT" != *"pinax.network"* ]]; then
  export SUBSTREAMS_API_TOKEN="${STREAMINGFAST_API_TOKEN:-}"
fi

# Ensure sourced env vars are inherited by child scripts.
export DATABASE_URL
export SUBSTREAMS_API_KEY
export SUBSTREAMS_API_TOKEN
export START_BLOCK
export STOP_BLOCK
export SUBSTREAMS_PARALLEL_WORKERS
export HANDLE_REORGS
export UNDO_BUFFER_SIZE
export OAPP_ADDRESS
export USD_TOKEN_ADDRESS
export USD_TOKEN_DECIMALS
export LAUNCHPAD_USD_DECIMALS
export DEFAULT_TOKEN_DECIMALS
export DEFAULT_TOKEN_SUPPLY

case "$ACTION" in
  setup)
    exec ./scripts/sink-sql-setup.sh
    ;;
  backfill)
    exec ./scripts/sink-sql-backfill.sh
    ;;
  live)
    exec ./scripts/sink-sql-live.sh
    ;;
  *)
    echo "Usage: $0 [setup|backfill|live]" >&2
    exit 1
    ;;
esac
