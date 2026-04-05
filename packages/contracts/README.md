# packages/contracts

Shared contracts for PulseoCore.

## Scope

This package directory is intended to hold:

- API-generated types from `openapi.yaml`
- shared JSON schemas
- event envelopes
- versioned payload examples

## First contract families

- auth
- profile
- checkins
- cravings
- rituals
- sos
- phoenix
- audit/review events

## Rule

When API payloads or event payloads change, the matching shared contracts must be updated in the same change set.
