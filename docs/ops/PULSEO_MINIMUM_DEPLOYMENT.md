# Pulseo minimum deployment

## Goal

Deploy a first GitHub-driven Pulseo version that preserves the existing chat behavior while exposing the certifiable runtime endpoints.

## What Pulseo minimum includes

- legacy-style web chat at `/`
- streaming chat endpoint at `/chat`
- simple health endpoint at `/health`
- runtime API at `/v1/...`
- minimum persistence layer
- OPC emission and manifest validation endpoints

## Files involved

- `services/api/pulseo_minimum.py`
- `services/api/Dockerfile.minimum`
- `services/api/requirements.minimum.txt`
- `infra/compose/docker-compose.minimum.yml`
- `legacy/vps_existing/pulseo_chat/index.html`

## Deployment notes

- the compose file expects `/etc/pulseo/staging.env`
- the app expects Ollama to be reachable from the container host
- the archive path `/opt/pulseo/archive` must exist
- PostgreSQL and Redis are included in the compose stack

## Migration role

Pulseo minimum is the transitional bridge between:

- the ad-hoc VPS chat service on port `7860`
- the repository-owned certifiable runtime

## Validation checklist

- `/health` returns ok
- `/v1/health` returns ok
- `/` serves the chat UI
- `/chat` streams model output
- `/v1/runtime/manifest/validate` accepts a valid manifest
- `/v1/runtime/opc/emit` writes an OPC artifact
