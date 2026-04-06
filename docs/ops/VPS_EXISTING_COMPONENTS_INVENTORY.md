# VPS existing components inventory

This document tracks components that are already present on the live VPS but were not originally created inside this repository.

## Known existing paths on the VPS

Under `/home/ubuntu/`:

- `pulseo_chat/`
  - `server.py`
  - `index.html`
  - `server.log`
  - `server.pid`
- `pulseo_master_deploy.sh`
- `ollama.log`
- `pulseo_tunnel.log`

## Current state

These files are part of the real VPS history and must be preserved as migration artifacts.

## Repository goal

The repository must contain:

1. a record that these components exist on the VPS,
2. a repeatable method to capture them,
3. a destination tree to import them into Git history,
4. a migration path away from ad-hoc server state toward repository-driven deployment.

## Planned repository destinations

- `legacy/vps_existing/pulseo_chat/`
- `legacy/vps_existing/scripts/`
- `legacy/vps_existing/logs/README.md`

## Important rule

Until the capture scripts are executed on the VPS, the repository only contains the inventory and import mechanism, not the actual live file contents.
