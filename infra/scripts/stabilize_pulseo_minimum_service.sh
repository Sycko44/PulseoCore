#!/usr/bin/env bash
set -Eeuo pipefail

sudo systemctl daemon-reload
sudo systemctl enable pulseo-minimum.service
sudo systemctl restart pulseo-minimum.service

sleep 2

systemctl is-active --quiet pulseo-minimum.service
curl -fsS http://127.0.0.1:8000/health

echo "OK"
