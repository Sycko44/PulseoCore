#!/usr/bin/env bash
set -eu

OUTDIR="${1:-/opt/pulseo/archive/legacy-captures}"
STAMP="$(date +%Y%m%d%H%M%S)"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

install -d -m 755 "$OUTDIR"

copy_if_exists() {
  src="$1"
  dst="$2"
  if [ -e "$src" ]; then
    cp -a "$src" "$dst"
  fi
}

mkdir -p "$TMPDIR/pulseo_chat" "$TMPDIR/scripts" "$TMPDIR/logs"
copy_if_exists "/home/ubuntu/pulseo_chat/server.py" "$TMPDIR/pulseo_chat/server.py"
copy_if_exists "/home/ubuntu/pulseo_chat/index.html" "$TMPDIR/pulseo_chat/index.html"
copy_if_exists "/home/ubuntu/pulseo_master_deploy.sh" "$TMPDIR/scripts/pulseo_master_deploy.sh"
copy_if_exists "/home/ubuntu/ollama.log" "$TMPDIR/logs/ollama.log"
copy_if_exists "/home/ubuntu/pulseo_tunnel.log" "$TMPDIR/logs/pulseo_tunnel.log"

tar -czf "$OUTDIR/legacy-vps-capture-$STAMP.tar.gz" -C "$TMPDIR" .

echo "Archived legacy VPS capture to $OUTDIR/legacy-vps-capture-$STAMP.tar.gz"
