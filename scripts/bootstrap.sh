#!/usr/bin/env bash
set -eu

if [ ! -f .env ]; then
  cp .env.example .env
  echo "[pulseocore] created .env from .env.example"
fi

echo "[pulseocore] starting local services"
docker compose up -d

echo "[pulseocore] bootstrap completed"
