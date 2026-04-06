# GitHub runner setup

## Target host

- host: `51.38.39.106`
- user: `ubuntu`
- base directory: `/home/ubuntu/actions-runner`

## Goal

Install a self-hosted GitHub Actions runner on the VPS with the label `pulseo` so repository deployment workflows can execute directly on the server.

## Manual setup outline

1. Create or reuse the directory `/home/ubuntu/actions-runner`.
2. Download the Linux x64 runner package from the official GitHub Actions runner releases page.
3. Extract it in `/home/ubuntu/actions-runner`.
4. Run the configuration step against the PulseoCore repository or owner with labels:
   - `self-hosted`
   - `pulseo`
5. Install and start the runner as a service.

## Service expectation

After setup, the runner should survive shell disconnects and system reboots.

## Validation

The runner is ready when:

- it appears online in GitHub repository settings
- the `deploy-staging.yml` workflow can target `runs-on: [self-hosted, pulseo]`
- the VPS executes the workflow without manual SSH intervention

## Notes

- Keep the runner under user `ubuntu` for now because the current VPS operational state already relies on that user.
- Migrate to a dedicated service account later if stricter separation becomes necessary.
