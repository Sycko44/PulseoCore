#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d_%H%M%S)"
BASE="/home/ubuntu"
FREEZE_DIR="$BASE/vps_relay/freezes/socle-minimal-github-pack_$TS"

mkdir -p "$FREEZE_DIR/systemd" "$FREEZE_DIR/nginx" "$FREEZE_DIR/app"

cp -a /etc/systemd/system/pulseo-minimum.service "$FREEZE_DIR/systemd/" 2>/dev/null || true
cp -a /etc/nginx/sites-available/pulseo-main "$FREEZE_DIR/nginx/" 2>/dev/null || true
cp -a /etc/nginx/sites-available/pulseo-admin "$FREEZE_DIR/nginx/" 2>/dev/null || true
cp -a /etc/nginx/sites-available/pulseo-www "$FREEZE_DIR/nginx/" 2>/dev/null || true

cp -a "$BASE/PulseoCore/services/api/pulseo_minimum.py" "$FREEZE_DIR/app/" 2>/dev/null || true
cp -a "$BASE/PulseoCore/services/api/settings.py" "$FREEZE_DIR/app/" 2>/dev/null || true

if [ -f "$BASE/PulseoCore/services/api/.runtime.env" ]; then
  sed -E 's/(SECRET|TOKEN|KEY|PASSWORD|PASS|AUTH|VAULT|OPENAI|OLLAMA|DATABASE|JWT)([^=]*)=.*/\1\2=REDACTED/I' \
    "$BASE/PulseoCore/services/api/.runtime.env" > "$FREEZE_DIR/app/runtime.env.redacted"
fi

curl -fsS http://127.0.0.1:8000/health > "$FREEZE_DIR/health.local.json"
curl -fsS https://pulseo.me/health > "$FREEZE_DIR/health.public.json"

find "$FREEZE_DIR" -type f -print0 | sort -z | xargs -0 sha256sum > "$FREEZE_DIR/hash_manifest.txt"

echo "$FREEZE_DIR"
