# Legacy port 7860 migration plan

## Context

The VPS currently serves a working Pulseo chat on port `7860` from `/home/ubuntu/pulseo_chat/`.

## Migration objective

Preserve the current live service while moving toward repository-driven deployment from GitHub.

## Strategy

### Phase 1 — capture
- inventory the existing service files
- copy the current live source into the repository under `legacy/vps_existing/`
- preserve logs as operational evidence, not as product source

### Phase 2 — parallel runtime
- keep the existing `7860` service alive
- bring up the new certifiable runtime in parallel through repository-controlled compose files
- validate healthchecks before any cut-over

### Phase 3 — controlled convergence
- compare current live behavior with the new runtime
- port any missing behaviors into the repository-owned runtime
- only then retire the ad-hoc server state

## Do not do

- do not delete `/home/ubuntu/pulseo_chat/` before capture
- do not replace port `7860` blindly
- do not treat logs as canonical source code

## Desired end state

GitHub becomes the source of truth while the current `7860` service is either:
- absorbed into the repository runtime, or
- kept as a clearly labeled legacy service until replacement is proven safe.
