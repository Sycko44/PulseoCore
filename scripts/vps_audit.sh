#!/usr/bin/env bash
set -eu

section() {
  printf '\n== %s ==\n' "$1"
}

section "system"
uname -a || true
[ -f /etc/os-release ] && cat /etc/os-release || true
printf 'user=%s\n' "$(whoami)"
printf 'hostname=%s\n' "$(hostname)"

section "resources"
free -h || true
df -h || true

section "tooling"
command -v git >/dev/null 2>&1 && git --version || echo "git: missing"
command -v docker >/dev/null 2>&1 && docker --version || echo "docker: missing"
if command -v docker >/dev/null 2>&1; then
  docker compose version || echo "docker compose: missing"
fi
command -v caddy >/dev/null 2>&1 && caddy version || echo "caddy: missing"
command -v vault >/dev/null 2>&1 && vault version || echo "vault: missing"
command -v ollama >/dev/null 2>&1 && ollama --version || echo "ollama: missing"

section "network"
ss -tulpn || true
curl -fsS https://github.com >/dev/null && echo "github: reachable" || echo "github: unreachable"

section "paths"
for path in /opt/pulseo /etc/pulseo /var/log/pulseo; do
  if [ -e "$path" ]; then
    echo "$path: present"
  else
    echo "$path: missing"
  fi
done

section "summary"
echo "Audit completed. Missing tooling and directories should be remediated before production deployment."
