#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

CHAIN="${TOKENLAYER_CHAIN:-}"
ACTION="${TOKENLAYER_ACTION:-live}"
AUTO_SETUP="${TOKENLAYER_AUTO_SETUP:-1}"

if [[ -z "$CHAIN" ]]; then
  echo "Set TOKENLAYER_CHAIN to one of: base-sepolia, bnb-testnet, ethereum, bnb, base, monad, polygon" >&2
  exit 1
fi

case "$CHAIN" in
  base-sepolia|bnb-testnet|ethereum|bnb|base|monad|polygon)
    RUNNER="./scripts/sink-sql-chain.sh"
    ;;
  *)
    echo "Unsupported TOKENLAYER_CHAIN: $CHAIN" >&2
    exit 1
    ;;
esac

if [[ "$AUTO_SETUP" == "1" && "$ACTION" != "setup" ]]; then
  "$RUNNER" "$CHAIN" setup
fi

exec "$RUNNER" "$CHAIN" "$ACTION"
