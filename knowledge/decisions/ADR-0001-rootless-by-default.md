# ADR-0001 — Rootless by Default

**Status:** Accepted

## Decision

Wonderland prefers rootless infrastructure using Lima and nerdctl where practical.

## Rationale

Rootless systems reduce host risk, improve recoverability, avoid unnecessary privileged daemons, and align with Wonderland's local-first platform model.

## Consequences

- Shared runtime conventions are required.
- Verification tooling must account for Lima and nerdctl.
- Platform services should avoid unnecessary host privileges.
