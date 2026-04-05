#!/usr/bin/env bash
set -eu

ENVIRONMENT="${1:-staging}"
API_URL="http://127.0.0.1:8000/v1/health"

if curl -fsS "$API_URL" >/dev/null; then
  echo "Healthcheck OK for $ENVIRONMENT"
else
  echo "Healthcheck FAILED for $ENVIRONMENT"
  exit 1
fi
