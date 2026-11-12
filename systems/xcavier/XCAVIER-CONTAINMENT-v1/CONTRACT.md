# XCAVIER-CONTAINMENT-v1

Version: 1.0.0
Status: PROPOSED

## Responsibility

Define and validate the integrity boundaries
of an operation affecting a person.

## Validation sequence

01. Record schema validation
02. Subject identification
03. Actor identification
04. Action identification
05. Purpose validation
06. Boundary classification
07. Authorization presence
08. Authorization binding
09. Consent-state validation
10. Expiration validation
11. Revocation validation
12. Evidence integrity
13. Final validation result

## Required invariants

C-001: Every operation has a unique action ID.

C-002: Every operation identifies its subject.

C-003: Every operation identifies its requesting actor.

C-004: Every operation declares its purpose.

C-005: Every operation declares its boundary.

C-006: Authorization must bind to the exact operation.

C-007: Authorization cannot be transferred.

C-008: Authorization expires.

C-009: Revocation invalidates future authorization.

C-010: Missing information fails closed.

C-011: Validation produces no execution side effects.

C-012: Consent cannot be inferred from silence.

## Boundary classifications

- INFORMATION
- ENVIRONMENT
- BODY
- COGNITIVE

## Output

ValidationResult:

- valid
- code
- reason

## Failure behavior

Every malformed, incomplete, expired,
revoked, or contradictory request is rejected.

Containment never performs the operation.

## Authorization continuity — v1.2

C-013: Authorization has a unique authorization identity.

C-014: Authorization must be resolved from its authoritative source.

C-015: Caller-supplied authorization snapshots are not authoritative.

C-016: Authorization must bind to the exact subject, actor, action,
and purpose.

C-017: Expiration and revocation invalidate future protected decisions.

C-018: Authorization validation must be repeated at protected
transition decision time.

C-019: Containment does not establish that a person's internal
state or consent is genuine merely from recorded boolean values.

C-020: Authorization records and their revisions must retain
provenance.

## Crystal authority

Crystal is the designated authoritative source for authorization
records and revocation state.

Containment receives the resolved authorization record and validates
its contents. It does not independently create, modify, or infer
authorization.

Unavailable or malformed authoritative records fail closed.
