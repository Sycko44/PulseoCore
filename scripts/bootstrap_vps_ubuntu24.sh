#!/usr/bin/env bash
set -eu

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  git \
  rsync \
  jq \
  unzip \
  python3 \
  python3-pip \
  python3-venv \
  nginx \
  certbot \
  python3-certbot-nginx

if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
fi

if ! docker compose version >/dev/null 2>&1; then
  sudo apt-get install -y docker-compose-plugin
fi

if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi

if ! command -v pm2 >/dev/null 2>&1; then
  sudo npm install -g pm2
fi

sudo install -d -m 755 /opt/pulseo
sudo install -d -m 700 /etc/pulseo
sudo install -d -m 755 /var/log/pulseo
sudo install -d -m 755 /opt/pulseo/archive/opc
sudo install -d -m 755 /opt/pulseo/archive/manifests

echo "Bootstrap complete. Re-login may be required for docker group membership."
