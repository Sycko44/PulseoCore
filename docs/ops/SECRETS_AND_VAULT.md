# Secrets and Vault integration

## Role of Vault

Vault is the authoritative runtime source for:

- JWT secrets
- database credentials
- redis credentials if enabled
- smtp credentials
- storage credentials
- opc signing material
- future short-lived machine credentials

## What must never happen

- no runtime secret committed in Git
- no production secret hardcoded in compose files
- no secret copied into documentation examples

## Recommended path model

- `secret/data/pulseo/staging/runtime`
- `secret/data/pulseo/prod/runtime`
- `secret/data/pulseo/shared/opc`

## Required runtime keys

### Core
- `APP_ENV`
- `APP_NAME`
- `APP_HOST`
- `APP_PORT`
- `WEB_BASE_URL`
- `MOBILE_API_BASE_URL`

### Security
- `SECRET_KEY`
- `JWT_SECRET`
- `JWT_ACCESS_TTL_MINUTES`
- `JWT_REFRESH_TTL_DAYS`

### Database
- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`
- `POSTGRES_HOST`
- `POSTGRES_PORT`
- `DATABASE_URL`

### Cache/queue
- `REDIS_HOST`
- `REDIS_PORT`
- `REDIS_URL`

### Storage/mail
- `OBJECT_STORAGE_ENDPOINT`
- `OBJECT_STORAGE_BUCKET`
- `OBJECT_STORAGE_ACCESS_KEY`
- `OBJECT_STORAGE_SECRET_KEY`
- `SMTP_HOST`
- `SMTP_PORT`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_FROM`

## Runtime policy

1. GitHub workflow authenticates to the VPS.
2. The VPS resolves secrets from Vault.
3. Secrets are rendered into `/etc/pulseo/<env>.env` with root-owned permissions.
4. Services consume only those runtime env files.
5. Rotation is done by updating Vault then redeploying or reloading the affected services.

## Ownership and permissions

- `/etc/pulseo/*.env` should be owned by `root:root`
- permission target: `0600`
- application containers should never be given write access to the secrets path

## Rotation model

### Manual rotation baseline
- update value in Vault
- re-run deployment for target environment
- validate healthchecks
- archive new deployment metadata

### Future hardening
- short-lived credentials where supported
- database credential rotation through Vault
- periodic key rotation for OPC signing material
