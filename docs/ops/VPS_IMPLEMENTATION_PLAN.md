# VPS implementation plan

## Goal

Deploy the minimum certifiable Pulseo core on the VPS so GitHub can drive deployment and the VPS can continue operating outside chat sessions.

## Target runtime layers

1. GitHub as source of truth for code and workflows.
2. VPS as long-running execution host.
3. Vault as source of truth for runtime secrets.
4. Certifiable execution runtime with manifest, validation, isolation, OPC, archive, and rollback.

## First production slice

The first slice to deploy is:

- reverse proxy
- api
- worker
- postgres
- redis
- vault integration
- github runner support
- manifest validation
- quarantine hooks
- opc generation
- archive ingest

## Sequence

### Step 1 - VPS prerequisites
- Ubuntu host ready
- Docker and Docker Compose installed
- Caddy installed or containerized
- pulseo user created
- `/opt/pulseo` created
- `/etc/pulseo` created for runtime env files

### Step 2 - GitHub deployment path
- self-hosted GitHub runner on VPS
- staging deploy workflow
- production deploy workflow
- deployment scripts checked into repo

### Step 3 - Runtime security baseline
- execution manifest schema
- OPC schema
- bundle verification hooks
- runtime env injected from Vault
- rollback and quarantine scripts

### Step 4 - Minimum live services
- API live at `api.pulseo.me`
- placeholder web shell at `pulseo.me`
- optional admin placeholder at `admin.pulseo.me`
- database and redis healthy
- worker healthy

### Step 5 - Operational proof
- healthchecks green
- deploy result written to GitHub logs
- release metadata stored on VPS
- OPC archive path separated from execution path

## Directory conventions

- `/opt/pulseo/staging`
- `/opt/pulseo/prod`
- `/opt/pulseo/archive`
- `/etc/pulseo/staging.env`
- `/etc/pulseo/prod.env`
- `/var/log/pulseo`

## Notes

This plan intentionally deploys the core before advanced sandbox/lot-33 capabilities. The VPS must first become a stable certifiable runtime before it becomes a full semantic production environment.
