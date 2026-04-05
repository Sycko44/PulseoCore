# PulseoCore release notes and deployment guide

## Environments

PulseoCore should be operated with at least:

- development
- staging
- production

## Deployment intent

- staging validates mobile/API/runtime integration
- production serves the Android release and admin workloads
- rollback must be possible for every release

## Minimum deployment sequence

1. Validate `openapi.yaml` and changed contracts.
2. Validate environment variables.
3. Run migrations if any.
4. Deploy API.
5. Run smoke checks on `/health` and critical endpoints.
6. Validate mobile-to-API connectivity on staging.
7. Promote to production.
8. Monitor logs, errors, and health checks.

## Rollback rule

Every release should define:

- rollback owner
- rollback command or procedure
- compatibility note for database changes

## Release gates

A release should not ship unless:

- `CHECKLIST_QA.md` is passed
- `CHECKLIST_RELEASE.md` is passed
- critical auth and MVP flows work on staging
- monitoring is active

## Mobile-specific gate

Before a Play Store submission:

- production API must be stable
- privacy policy must be published
- screenshots and store assets must be ready
- package signing must be ready
