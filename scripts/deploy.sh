#!/usr/bin/env bash
set -eu

ENVIRONMENT="${1:-staging}"
COMMIT_SHA="${2:-unknown}"
ROOT_DIR="/opt/pulseo/${ENVIRONMENT}"
RELEASES_DIR="${ROOT_DIR}/releases"
CURRENT_LINK="${ROOT_DIR}/current"
PREVIOUS_LINK="${ROOT_DIR}/previous"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
RELEASE_DIR="${RELEASES_DIR}/${TIMESTAMP}-${COMMIT_SHA}"
COMPOSE_FILE="infra/compose/docker-compose.${ENVIRONMENT}.yml"
PROJECT_NAME="pulseo-${ENVIRONMENT}"

install -d -m 755 "$RELEASES_DIR"
install -d -m 755 /var/log/pulseo

rsync -a --delete ./ "$RELEASE_DIR/"

if [ -L "$CURRENT_LINK" ]; then
  PREV_TARGET="$(readlink -f "$CURRENT_LINK")"
  ln -sfn "$PREV_TARGET" "$PREVIOUS_LINK"
fi

ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"
cd "$CURRENT_LINK"

bash scripts/fetch-secrets-from-vault.sh "$ENVIRONMENT"
docker compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" up -d --build
bash scripts/healthcheck.sh "$ENVIRONMENT"

echo "$COMMIT_SHA" > "${ROOT_DIR}/last_successful_commit"
echo "Deploy success for $ENVIRONMENT at commit $COMMIT_SHA"
