# Autopilot rules for PulseoCore

## Purpose

This document defines how repository progress can continue autonomously without asking for approval at every small step.

## Baseline

Autonomous work must stay aligned with these fixed constraints:

- Pulseo 1.2 remains the current product source of truth
- open source first
- self-hostable on a VPS
- no mandatory proprietary dependency for core operation
- Android MVP connected to the VPS is the current delivery priority

## Green zone - allowed without repeated approval

The repository may continue to evolve autonomously for:

- documentation improvements
- repository structure improvements
- API contracts and shared schemas
- implementation of non-destructive code scaffolds
- tests and CI
- design-system tokens and reusable components
- bootstrap and deployment scripts
- staging and local environment preparation
- worker, admin, mobile and API skeletons
- semantic library scaffolding aligned with the current roadmap

## Orange zone - pause and ask before proceeding

Stop and ask before:

- replacing the current product canon
- introducing a major runtime dependency that changes the architecture
- changing the project license
- changing core security assumptions in a non-trivial way
- widening scope far beyond the Android MVP + VPS baseline

## Red zone - never proceed without explicit approval

Do not proceed autonomously for:

- secrets or private keys
- irreversible production actions
- destructive deletion or force-push workflows
- publishing to app stores
- paid service activation
- legal or licensing changes
- exposing personal or sensitive data

## Default implementation order

Autonomous work should follow this order unless a blocking dependency forces a swap:

1. contracts and repository structure
2. executable backend skeletons
3. worker and background execution
4. mobile shell and admin shell
5. tests and CI
6. staging/deployment preparation
7. design-system implementation
8. release readiness
9. semantic sandbox library MVP

## Commit rules

Autonomous changes should use:

- small coherent commits
- clear commit messages
- one subject per batch when possible
- documentation updates alongside behavior changes

Examples:

- `feat: add api auth skeleton`
- `chore: add staging compose`
- `docs: update release flow`
- `test: add api smoke tests`

## Reporting rule

Autonomous work should still leave a short trace in conversation after each batch:

- what changed
- current commit reference when available
- what comes next
- what is blocked

## Stop conditions

Pause autonomous progress when:

- the next step would cross into orange or red zone
- repository changes require credentials or infrastructure access not available here
- there is ambiguity about product direction strong enough to risk architectural drift

## Current priority stack

At the time of this document, the next autonomous priorities are:

1. executable API skeleton
2. executable worker skeleton
3. basic CI
4. mobile/admin shell progression
5. staging/deployment docs and scripts
6. semantic library groundwork without delaying the MVP
