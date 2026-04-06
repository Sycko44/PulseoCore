#!/usr/bin/env bash
set -eu

ENVIRONMENT="${1:-staging}"
BASE_URL="${2:-http://127.0.0.1:8000}"

check() {
  local url="$1"
  local name="$2"
  if curl -fsS "$url" >/dev/null; then
    echo "[OK] $name"
  else
    echo "[FAIL] $name"
    exit 1
  fi
}

check "$BASE_URL/health" "pulseo minimum health"
check "$BASE_URL/v1/health" "runtime health"
check "$BASE_URL/" "legacy-compatible UI"

echo "Pulseo minimum healthchecks OK for $ENVIRONMENT"
