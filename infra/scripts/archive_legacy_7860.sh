#!/usr/bin/env bash
set -Eeuo pipefail

TS="$(date +%Y%m%d_%H%M%S)"
BASE="/home/ubuntu"
ARCHIVE_DIR="$BASE/vps_relay/legacy_archives/pulseo_chat_legacy_7860_$TS"

mkdir -p "$ARCHIVE_DIR"

if ss -lnt | awk '{print $4}' | grep -q ':7860$'; then
  echo "ERREUR: port 7860 actif. Archivage refusé tant que le legacy tourne."
  exit 1
fi

if [ -d "$BASE/pulseo_chat" ]; then
  cp -a "$BASE/pulseo_chat/." "$ARCHIVE_DIR/"
fi

cat > "$ARCHIVE_DIR/ARCHIVE_NOTE.md" <<EOF2
# Archive legacy Pulseo Chat 7860

Date: $TS

Le legacy 7860 est archivé.
Il ne doit pas être relancé sans manifest validé.
EOF2

find "$ARCHIVE_DIR" -type f -print0 | sort -z | xargs -0 sha256sum > "$ARCHIVE_DIR/hash_manifest.txt"

echo "$ARCHIVE_DIR"
