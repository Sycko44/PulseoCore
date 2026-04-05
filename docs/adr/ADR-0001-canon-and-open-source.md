# ADR-0001 - Canon and open-source baseline

## Status
Accepted

## Context

The project contains multiple historical branches, conceptual archives, runtime notes, and product drafts. Without a single product canon, execution becomes ambiguous. The repository also needs a clear open-source baseline.

## Decision

- Pulseo 1.2 is the current product source of truth.
- Historical branches inform the project but do not override the canon.
- PulseoCore remains open source and self-hostable.
- The core runtime must not require proprietary dependencies to function.
- New work should be attached as docs, contracts, backlog items, ADRs, or implementation changes aligned with the canon.

## Consequences

- Delivery is easier to sequence.
- Junior contributors get a clearer reference point.
- Documentation and architecture become easier to audit and fork.
