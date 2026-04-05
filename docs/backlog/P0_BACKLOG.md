# P0 backlog

## Goal

Ship the first Android MVP connected to the VPS with a stable API baseline and minimal operational readiness.

## P0-001 - Repository bootstrap

### Outcome
The repository starts locally with documented services and environment handling.

### Done when
- `.env.example` exists
- `docker-compose.yml` exists
- `README.setup.md` exists
- team can start local services

## P0-002 - Auth contract and session flow

### Outcome
The mobile client can register, login, refresh, and retrieve the current profile.

### Done when
- auth endpoints implemented
- bearer auth documented
- refresh flow tested
- unauthorized errors handled

## P0-003 - Check-in MVP

### Outcome
A user can submit and retrieve check-ins.

### Done when
- create/list check-ins implemented
- validation rules enforced
- timestamps stored
- mobile path covered by QA

## P0-004 - Cravings MVP

### Outcome
A user can log cravings and retrieve recent entries.

### Done when
- create/list cravings implemented
- trigger and notes fields supported
- error states defined

## P0-005 - Rituals MVP

### Outcome
The app can fetch ritual suggestions and mark a ritual as completed.

### Done when
- ritual listing implemented
- completion endpoint implemented
- completion reflected in user timeline or metrics

## P0-006 - SOS MVP

### Outcome
The user can trigger a fast SOS flow and receive a minimal protocol.

### Done when
- SOS endpoint implemented
- response shape stable
- logging/audit rule defined

## P0-007 - Phoenix summary MVP

### Outcome
The app can retrieve a progression summary.

### Done when
- phoenix endpoint implemented
- summary schema stable
- empty state defined

## P0-008 - Mobile shell

### Outcome
The Android/mobile app has working screens for the MVP flows.

### Done when
- onboarding shell exists
- auth screens exist
- home exists
- check-in, cravings, SOS, rituals, Phoenix screens exist
- error and loading states exist

## P0-009 - Design tokens and core components

### Outcome
The first reusable UI layer exists.

### Done when
- color tokens defined
- typography scale defined
- spacing scale defined
- button, card, input and alert components exist

## P0-010 - Operational minimum

### Outcome
The stack is observable and releasable.

### Done when
- health endpoint used in deploy checks
- logs available
- QA checklist applied
- release checklist applied
- rollback owner identified
