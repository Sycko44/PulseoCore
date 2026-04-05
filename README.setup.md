# PulseoCore setup

## 1. Local prerequisites

Recommended baseline:

- Git
- Docker and Docker Compose
- Node.js 20+
- Python 3.12+

## 2. First local bootstrap

1. Clone the repository.
2. Copy `.env.example` to `.env`.
3. Adjust local secrets.
4. Start local services:

```bash
cp .env.example .env
docker compose up -d
```

## 3. Initial repository shape

- `openapi.yaml` - MVP API contract
- `docs/autopilot-pack/` - pilot pack and execution docs
- `apps/mobile/` - Android/mobile client
- `apps/admin/` - back-office and studio web
- `services/api/` - main API service
- `services/worker/` - async jobs and sandbox/review workers
- `packages/contracts/` - shared API and event contracts
- `packages/design-system/` - shared design tokens and UI rules

## 4. Expected next steps

The current repository state is a scaffold. The team should next add:

- real API implementation in `services/api/`
- real worker implementation in `services/worker/`
- mobile app shell in `apps/mobile/`
- shared contract generation in `packages/contracts/`
- design tokens and UI kit in `packages/design-system/`

## 5. Local validation

Before opening a large PR, validate at least:

- `.env` loads correctly
- Docker services start
- API contract remains valid YAML
- documentation impacted by the change is updated
