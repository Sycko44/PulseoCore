#!/usr/bin/env bash
set -eu

if [ ! -f openapi.yaml ]; then
  echo "openapi.yaml not found"
  exit 1
fi

echo "[pulseocore] openapi.yaml found"
python - <<'PY'
import yaml
with open('openapi.yaml', 'r', encoding='utf-8') as f:
    data = yaml.safe_load(f)
assert 'openapi' in data, 'Missing openapi version'
assert 'paths' in data, 'Missing paths'
print('[pulseocore] openapi basic validation passed')
PY
