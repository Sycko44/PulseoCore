#!/usr/bin/env bash
set -eu

CAPTURE_ROOT="${1:-$PWD/legacy/vps_existing}"
VPS_HOME="/home/ubuntu"

install -d -m 755 "$CAPTURE_ROOT/pulseo_chat"
install -d -m 755 "$CAPTURE_ROOT/scripts"
install -d -m 755 "$CAPTURE_ROOT/logs"

copy_if_exists() {
  src="$1"
  dst="$2"
  if [ -e "$src" ]; then
    cp -a "$src" "$dst"
    echo "captured: $src"
  else
    echo "missing: $src"
  fi
}

copy_if_exists "$VPS_HOME/pulseo_chat/server.py" "$CAPTURE_ROOT/pulseo_chat/server.py"
copy_if_exists "$VPS_HOME/pulseo_chat/index.html" "$CAPTURE_ROOT/pulseo_chat/index.html"
copy_if_exists "$VPS_HOME/pulseo_master_deploy.sh" "$CAPTURE_ROOT/scripts/pulseo_master_deploy.sh"
copy_if_exists "$VPS_HOME/ollama.log" "$CAPTURE_ROOT/logs/ollama.log"
copy_if_exists "$VPS_HOME/pulseo_tunnel.log" "$CAPTURE_ROOT/logs/pulseo_tunnel.log"

cat > "$CAPTURE_ROOT/logs/README.md" <<'EOF'
# Legacy VPS logs

These logs were captured from the live VPS for migration reference only.
They are not canonical source code.
EOF

echo "Capture completed into $CAPTURE_ROOT"
