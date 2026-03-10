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
: "${SUBSTREAMS_ENDPOINT:?Set SUBSTREAMS_ENDPOINT in environment (typically loaded by chain wrapper)}"
: "${UNISWAP_V3_FACTORY:?Set UNISWAP_V3_FACTORY in environment (typically loaded by chain wrapper)}"
OAPP_ADDRESS="${OAPP_ADDRESS:-0xf7d116F1a1AC7c34372e52cf5763c58DcF43185a}"
USD_TOKEN_ADDRESS="${USD_TOKEN_ADDRESS:-0xED0E8956D5e7b04560460BE6B3811B0b31cEe8E1}"
USD_TOKEN_DECIMALS="${USD_TOKEN_DECIMALS:-6}"
LAUNCHPAD_USD_DECIMALS="${LAUNCHPAD_USD_DECIMALS:-18}"
DEFAULT_TOKEN_DECIMALS="${DEFAULT_TOKEN_DECIMALS:-18}"
DEFAULT_TOKEN_SUPPLY="${DEFAULT_TOKEN_SUPPLY:-1000000000}"
if [[ -z "${SUBSTREAMS_API_TOKEN:-}" && -z "${SUBSTREAMS_API_KEY:-}" ]]; then
  echo "Set SUBSTREAMS_API_TOKEN or SUBSTREAMS_API_KEY in environment (.substreams.env or shared/chain sink env)" >&2
  exit 1
fi

MANIFEST="${MANIFEST:-./substreams.yaml}"
START_BLOCK="${START_BLOCK:-}"
STOP_BLOCK="${STOP_BLOCK:-}"
AUTH_ARGS=()
EXTRA_HEADERS=()
RANGE_ARG=()

ARGS=(
  "$DATABASE_URL"
  "$MANIFEST"
)
FLAG_ARGS=(
  --endpoint "$SUBSTREAMS_ENDPOINT"
  --bytes-encoding 0xhex
)
HANDLE_REORGS="${HANDLE_REORGS:-1}"
UNDO_BUFFER_SIZE="${UNDO_BUFFER_SIZE:-200}"

if [[ "$HANDLE_REORGS" == "1" ]]; then
  FLAG_ARGS+=(--undo-buffer-size "$UNDO_BUFFER_SIZE")
else
  FLAG_ARGS+=(--final-blocks-only)
fi

if [[ -n "$START_BLOCK" || -n "$STOP_BLOCK" ]]; then
  RANGE_ARG=("${START_BLOCK}:${STOP_BLOCK}")
fi

if [[ -n "${SUBSTREAMS_API_KEY:-}" ]]; then
  AUTH_ARGS=(-H "x-api-key: ${SUBSTREAMS_API_KEY}")
elif [[ -n "${SUBSTREAMS_API_TOKEN:-}" ]]; then
  AUTH_ARGS=(--api-token-envvar SUBSTREAMS_API_TOKEN)
fi

if [[ -n "${SUBSTREAMS_PARALLEL_WORKERS:-}" ]]; then
  EXTRA_HEADERS+=(-H "X-Substreams-Parallel-Workers: ${SUBSTREAMS_PARALLEL_WORKERS}")
fi

FLAG_ARGS+=(-p "store_uniswap_v3_pools=uniswap_v3_factory=${UNISWAP_V3_FACTORY}")
FLAG_ARGS+=(-p "store_uniswap_v3_pool_meta=uniswap_v3_factory=${UNISWAP_V3_FACTORY}")
FLAG_ARGS+=(-p "map_events=uniswap_v3_factory=${UNISWAP_V3_FACTORY}&oapp_address=${OAPP_ADDRESS}&usd_token_address=${USD_TOKEN_ADDRESS}&usd_token_decimals=${USD_TOKEN_DECIMALS}&launchpad_usd_decimals=${LAUNCHPAD_USD_DECIMALS}&default_token_decimals=${DEFAULT_TOKEN_DECIMALS}&default_token_supply=${DEFAULT_TOKEN_SUPPLY}")

substreams-sink-sql run "${ARGS[@]}" "${RANGE_ARG[@]}" "${FLAG_ARGS[@]}" "${AUTH_ARGS[@]}" "${EXTRA_HEADERS[@]}"
