# Live VPS import instructions

## Goal

Bring already-running VPS artifacts into Git history so the repository becomes the complete installation and deployment reference.

## Files to import first

- `/home/ubuntu/pulseo_chat/server.py`
- `/home/ubuntu/pulseo_chat/index.html`
- `/home/ubuntu/pulseo_master_deploy.sh`

## Recommended sequence on the VPS

1. Clone or pull the latest `PulseoCore` repository.
2. Run `scripts/capture_existing_vps_components.sh` from the repository root.
3. Review captured files under `legacy/vps_existing/`.
4. Commit the captured files into Git.
5. Compare legacy behavior with the repository-owned runtime.
6. Migrate features into the main runtime before retiring legacy service state.

## Why this matters

Without this capture step, GitHub cannot truly be the full historical installation and deployment record because part of the active system still lives only on the VPS.
