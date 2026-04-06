# Repository completeness status

## Already present in the repository

### VPS and deployment
- VPS implementation plan
- session continuity state from 2026-04-06
- secrets and Vault guide
- Ubuntu 24 bootstrap script
- GitHub runner setup guide
- staging and production compose files
- certifiable staging and production compose files
- Caddy configuration
- public minimum shell page
- audit, deploy, healthcheck, rollback scripts

### Runtime certifiable minimum
- execution manifest schema
- OPC schema
- runtime settings module
- minimum persistence layer
- runtime certification helpers
- minimum certifiable FastAPI runtime
- database bootstrap entrypoint
- runtime Dockerfile
- runtime env example

### Legacy migration
- inventory of existing VPS components
- migration plan for legacy 7860 service
- capture script for existing VPS components
- archive script for existing VPS components
- legacy landing zone readme

## Not yet committed as exact live content

The repository still does not contain the exact live contents of the following VPS files because they must first be captured from the server:

- `/home/ubuntu/pulseo_chat/server.py`
- `/home/ubuntu/pulseo_chat/index.html`
- `/home/ubuntu/pulseo_master_deploy.sh`

## Meaning

The repository is now structurally complete for installation and deployment planning, but still needs live VPS capture and final workflow wiring for full repository-driven replacement.
