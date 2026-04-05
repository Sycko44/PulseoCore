# System context

## Goal

Describe PulseoCore at the system level so a new team can understand boundaries quickly.

## Core actors

- end user on Android/mobile
- admin/operator on web admin
- VPS-hosted PulseoCore services
- data stores and object storage
- optional notification/email providers

## External view

### Mobile client
Consumes the API over HTTPS and presents the user-facing product.

### Admin client
Used by operators and content managers to review, configure, and publish.

### PulseoCore backend
Owns auth, profile, check-ins, cravings, rituals, SOS, Phoenix summary, review flow, audit hooks, and semantic library integration.

### Storage
Database, cache/queue, object storage.

## Boundary rule

The mobile app should stay light. Deep logic, audit, review, and semantic processing stay server-side.
