# Legacy VPS existing components

This directory is the repository landing zone for components that already existed on the live VPS before the repository became the source of truth.

## Expected captured content

- `pulseo_chat/server.py`
- `pulseo_chat/index.html`
- `scripts/pulseo_master_deploy.sh`
- optional logs captured for migration reference only

## Purpose

This directory preserves historical VPS state while the project transitions toward GitHub-driven deployment.

## Rules

- source code captured here may later be merged into the main runtime
- logs are reference artifacts, not canonical source code
- nothing in this directory should be treated as the long-term production architecture without review
