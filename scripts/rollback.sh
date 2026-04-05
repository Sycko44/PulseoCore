#!/usr/bin/env bash
set -eu

ENVIRONMENT="${1:-staging}"
ROOT_DIR="/opt/pulseo/${ENVIRONMENT}"
CURRENT_LINK="${ROOT_DIR}/current"
PREVIOUS_LINK="${ROOT_DIR}/previous"
COMPOSE_FILE="infra/compose/docker-compose.${ENVIRONMENT}.yml"
PROJECT_NAME="pulseo-${ENVIRONMENT}"

if [ ! -L "$PREVIOUS_LINK" ]; then
  echo "No previous release found for rollback"
  exit 1
fi

PREVIOUS_TARGET="$(readlink -f "$PREVIOUS_LINK")"
ln -sfn "$PREVIOUS_TARGET" "$CURRENT_LINK"
cd "$CURRENT_LINK"

docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" up -d --build
bash scripts/healthcheck.sh "$ENVIRONMENT"

echo "Rollback successful for $ENVIRONMENT"
