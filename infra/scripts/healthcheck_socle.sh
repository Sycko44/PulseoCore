#!/usr/bin/env bash
set -Eeuo pipefail

echo "== Healthcheck socle Pulseo =="

systemctl is-active --quiet nginx.service
systemctl is-active --quiet ollama.service
systemctl is-active --quiet pulseo-minimum.service

LOCAL_HEALTH="$(curl -fsS http://127.0.0.1:8000/health)"
PUBLIC_HEALTH="$(curl -fsS https://pulseo.me/health)"

echo "Local:  $LOCAL_HEALTH"
echo "Public: $PUBLIC_HEALTH"

echo "$LOCAL_HEALTH" | grep -q '"status":"ok"'
echo "$PUBLIC_HEALTH" | grep -q '"status":"ok"'

if ss -lnt | awk '{print $4}' | grep -q ':7860$'; then
  echo "ERREUR: port legacy 7860 actif"
  exit 1
fi

echo "OK"
