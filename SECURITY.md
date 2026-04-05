# Security Policy

## Scope

PulseoCore includes product, runtime, consent, privacy, safety, and sandbox-related components. Please report vulnerabilities responsibly.

## Please do not disclose publicly first

If you find a vulnerability, do not open a public issue with exploit details.

## Preferred report content

Please include:

- affected component;
- impact;
- reproduction steps;
- proof of concept if safe;
- suggested mitigation if known.

## Sensitive areas

Please treat these as especially sensitive:

- authentication and session handling;
- consent and privacy flows;
- data export and deletion;
- review and promotion gates;
- sandbox execution and runtime isolation;
- VPS deployment and secrets handling.

## Response goals

Best effort goals:

- acknowledge report quickly;
- assess severity;
- prepare a fix or mitigation;
- document the change;
- publish guidance once users are safe.

## Operational rule

No secret should be committed to the repository. Use environment variables and deployment-specific secret management.
