#!/usr/bin/env bash
set -eu

ENVIRONMENT="${1:-staging}"
VAULT_KV_PATH="${2:-secret/data/pulseo/${ENVIRONMENT}/runtime}"
OUTFILE="/etc/pulseo/${ENVIRONMENT}.env"

if ! command -v vault >/dev/null 2>&1; then
  echo "vault CLI is required"
  exit 1
fi

if [ -z "${VAULT_ADDR:-}" ]; then
  echo "VAULT_ADDR must be set"
  exit 1
fi

if [ -z "${VAULT_TOKEN:-}" ]; then
  echo "VAULT_TOKEN must be set"
  exit 1
fi

TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

vault kv get -format=json "$VAULT_KV_PATH" \
  | python -c 'import json,sys; data=json.load(sys.stdin)["data"]["data"]; [print(f"{k}={v}") for k,v in data.items()]' \
  > "$TMPFILE"

install -d -m 700 /etc/pulseo
install -m 600 "$TMPFILE" "$OUTFILE"

echo "Rendered runtime env to $OUTFILE"
