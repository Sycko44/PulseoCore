# Container view

## Core containers

### apps/mobile
Android/mobile client.

### apps/admin
Back-office and studio web.

### services/api
Main HTTP API and auth/session entrypoint.

### services/worker
Async jobs, review, notifications, semantic ingestion, sandbox orchestration.

### packages/contracts
Shared payload and event contracts.

### packages/design-system
Shared design tokens and UI guidance.

### data services
- PostgreSQL
- Redis
- Object storage

## Flow summary

Mobile and admin call the API.
The API persists state and dispatches async work.
Workers process background jobs and write results back to storage.
The semantic library and sandbox logic should live behind API/worker boundaries, not inside the clients.
