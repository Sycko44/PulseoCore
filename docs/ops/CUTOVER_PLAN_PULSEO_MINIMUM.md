# Cutover plan — Pulseo minimum

## Goal

Move from the live ad-hoc chat service on port `7860` toward the repository-owned `Pulseo minimum` deployment without breaking the current user-facing experience.

## Current live state

- live chat exists on port `7860`
- Ollama is running on the VPS
- repository now contains the imported legacy assets and the new Pulseo minimum runtime bridge

## Cutover strategy

### Phase 1 — parallel deploy
- deploy `Pulseo minimum` in parallel from GitHub
- keep the old `7860` service alive
- validate `/health`, `/v1/health`, `/`, and `/chat`

### Phase 2 — compare behavior
- compare UI rendering with the legacy `index.html`
- compare chat streaming behavior against the live `7860` service
- compare Ollama reachability and latency

### Phase 3 — controlled traffic shift
- route public traffic to the repository-owned service
- keep the legacy service available for fast rollback during the transition window

### Phase 4 — cleanup
- once stable, retire the ad-hoc launch path
- preserve the legacy files in `legacy/vps_existing/`
- document the final topology

## Rollback rule

If Pulseo minimum fails any of the following checks, rollback to the old service path:

- `/health`
- `/v1/health`
- `/`
- `/chat`
- Ollama response streaming

## Success condition

Pulseo minimum becomes the default user-facing entry while preserving repository ownership, deployment repeatability, and certifiable runtime expansion.
