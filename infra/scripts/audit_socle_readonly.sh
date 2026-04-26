#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d_%H%M%S)"
BASE="/home/ubuntu"
AUDIT_DIR="$BASE/vps_relay/audits/socle-readonly_$TS"

mkdir -p "$AUDIT_DIR"

{
  echo "# Audit socle read-only"
  echo
  echo "Date: $TS"
  echo
  echo "## OS"
  lsb_release -a 2>/dev/null || cat /etc/os-release
  echo
  echo "## Services"
  systemctl --no-pager --type=service --state=running | grep -Ei 'pulseo|audit|vault|ollama|nginx|runner|github|actions' || true
  echo
  echo "## Ports"
  ss -lntup || true
  echo
  echo "## Health local"
  curl -fsS http://127.0.0.1:8000/health || true
  echo
  echo "## Health public"
  curl -fsS https://pulseo.me/health || true
} > "$AUDIT_DIR/AUDIT_SOCLE_READONLY.md"

find "$AUDIT_DIR" -type f -print0 | sort -z | xargs -0 sha256sum > "$AUDIT_DIR/hash_manifest.txt"

echo "$AUDIT_DIR"
