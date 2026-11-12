# XCAVIER-ENFORCEMENT-v1

Version: 1.0.0
Status: PROPOSED

## Responsibility

Enforce authorization and transition decisions.

## Dependency

XCAVIER-ENFORCEMENT-v1 MUST use
XCAVIER-CONTAINMENT-v1.

It MUST NOT independently redefine
containment validation rules.

## Decision sequence

01. Receive proposed operation.
02. Invoke canonical containment validator.
03. Inspect validation result.
04. Reject invalid results.
05. Verify authorization remains current.
06. Verify transition is permitted.
07. Produce an accountable decision.
08. Return ACCEPT or REJECT.

## Required invariants

E-001: No validation bypass.

E-002: No implicit authorization.

E-003: No acceptance after revocation.

E-004: No acceptance after expiration.

E-005: No unauthorized transition.

E-006: No decision reuse across unrelated actions.

E-007: No fail-open exception handling.

E-008: No execution side effects.

E-009: Preserve rejection provenance.

E-010: Every decision has a unique decision ID.

## Decisions

ACCEPT:
All required conditions have passed.

REJECT:
Any required condition has failed.

## Important

ACCEPT is not an instruction to physically
execute an action.

It is a scoped authorization decision.

## Authorization continuity — v1.2

E-011: Protected decisions require an authoritative authorization lookup.

E-012: Caller-supplied authorization snapshots cannot override Crystal.

E-013: Every protected decision records the authorization identity
and authoritative record revision.

E-014: An authorization lookup failure must reject the decision.

E-015: An earlier ACCEPT decision is not a reusable execution capability.

E-016: Execution systems must independently verify authorization
and revision validity immediately before protected execution.

E-017: Revocation and cancellation exits must remain available
without requiring valid authorization.

## Crystal integration

Enforcement uses the CrystalAuthorizationAuthority interface.

The adapter must perform a fresh authoritative read. Cached or
unverified authorization state must not be used.

The storage implementation is injected through a reader interface.
No assumed Crystal storage API is part of this contract.
