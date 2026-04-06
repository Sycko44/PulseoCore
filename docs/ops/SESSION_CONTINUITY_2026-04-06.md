# Session continuity — 2026-04-06

## Real VPS state

- Host IP: `51.38.39.106`
- SSH user: `ubuntu`
- OS: `Ubuntu 24.04.4 LTS`
- CPU: `12 cores`
- RAM: `45 GB` with target upgrade to `64 GB`
- Disk: `288 GB`, around `274 GB` free
- SSH from Termux: working without password prompt using key auth

## Already deployed and confirmed working

- reverse SSH tunnel from Termux to VPS
- Ollama on port `11434`
- `qwen3:14b` installed and operational
- existing Pulseo chat at `http://51.38.39.106:7860`

## Missing runtime tooling on VPS

- Node.js 22
- PM2
- Nginx
- Certbot
- GitHub self-hosted runner

## Existing important VPS paths

- `/home/ubuntu/pulseo_chat/`
- `/home/ubuntu/pulseo_master_deploy.sh`
- `/home/ubuntu/ollama.log`
- `/home/ubuntu/pulseo_tunnel.log`

## Infrastructure direction

The phone remains a light client and sensor hub. The VPS remains the execution brain. The repository deployment path must therefore preserve this split:

- GitHub = versioned source of truth
- VPS = continuous execution host
- phone/Termux = thin pilot and fallback control surface

## Immediate consequence for repository work

Repository defaults should now assume:

- deployment user `ubuntu`
- first live host `51.38.39.106`
- Ubuntu 24.04 base
- Ollama already present
- existing chat service on port `7860` must be preserved during migration
- GitHub runner still needs to be installed
