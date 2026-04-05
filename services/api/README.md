# services/api

Main API service for PulseoCore.

## Responsibilities

- auth and sessions
- profile
- check-ins
- cravings
- rituals
- SOS
- Phoenix summary
- consent-aware logging and audit hooks

## Inputs

- HTTP requests from mobile/admin clients
- background jobs and event triggers

## Outputs

- JSON API responses
- audit events
- database writes
- job dispatch to workers
