# Mattie's Room — Universal Personal Zone v1

**Status:** Declarative foundation; runtime integration not yet implemented or certified  
**Manifest:** `config/wonderland/zones/matties-room.json`  
**Schema:** `schemas/personal-zone.schema.json`

## Intent

Mattie's Room is both an inhabitable personal environment and a persistent control point for entering, creating, discovering, governing, and connecting other environments. It spans physical reality and non-reality without asserting that every modeled environment physically exists.

The model is universal: environment identity and governance are shared, while each environment retains its own nature, topology, rules, capabilities, and evidence.

## Core invariants

1. **Discovery is not enrollment.** Discovery may create or refresh a candidate record only.
2. **Enrollment is explicit.** A candidate becomes a member only after an authenticated, attributable approval.
3. **Authorization is explicit and deny-by-default.** Membership grants no capabilities. Every grant names its subject, resource, capabilities, scope, validity, and revocation state.
4. **Authorization is checked at use.** Cached sessions and delegated Sparks must not silently bypass revoked or expired grants.
5. **Reality classification is descriptive, not a trust level.** Physical, virtual, simulated, imagined, abstract, hybrid, and computational environments use the same governance contract.
6. **Memory outlives execution.** Crystal persistence is independent of Spark lifetime.
7. **Execution is contained.** Sparks execute only within authorized Veil boundaries.
8. **Relationships are governed.** Crystal Mesh connects identities and environments through explicit relationships and evidence.
9. **Evidence proves outcomes, not intentions.** Requested actions are not recorded as successful until independently verified.
10. **Discovery is privacy-bounded.** Providers must be explicitly enabled, minimize collected attributes, identify their provenance, and avoid collecting secrets. Location, sensors, network scans, and external accounts are not implicitly enabled.
11. **Lifecycle changes are reversible where possible.** Suspension, grant revocation, membership retirement, and recovery are explicit transitions with evidence.
12. **Untrusted announcements are candidates only.** A mesh announcement, filesystem artifact, or discovered endpoint cannot self-enroll or authorize itself.

## Environment model

An environment is a first-class, addressable object with its own identity and lifecycle. Its kind may be:

- `physical`: rooms, buildings, places, and tangible surroundings.
- `virtual`: virtual worlds, VR spaces, and persistent digital spaces.
- `simulated`: modeled worlds and controlled simulations.
- `imagined`: fictional, dreamlike, or creative environments represented as authored models.
- `abstract`: conceptual spaces and formal models.
- `hybrid`: environments combining physical and digital components.
- `computational`: Sparks, sandboxes, virtual machines, and execution workspaces.

The type does not establish that an environment is real, safe, trusted, reachable, or authorized.

## Lifecycle

```text
discovered -> pending_review -> enrolled -> authorized
     |              |               |            |
     |              +-> rejected    +-> suspended
     |                                  |
     +-> rediscovered                   +-> recovery review
```

Additional rules:

- `discovered` and `pending_review` have no membership privileges.
- `enrolled` means membership was explicitly approved; it does not imply any access grant.
- `authorized` means one or more explicit, scoped grants are active; it is not a permanent trust label.
- Revoking the last grant returns an enrolled environment to `enrolled`.
- Suspension blocks governed interactions until reviewed.
- Retirement is explicit and retains history; rediscovery must not silently restore membership or grants.
- Replaying discovery inputs must be idempotent and must not create duplicate identities or privileges.

## Discovery provider contract

Each provider must declare its identifier, source kind, enabled state, required permissions, collection scope, and evidence format. Provider output is normalized into candidate records containing:

- stable candidate identity when available, otherwise a clearly marked provisional identity;
- environment kind and observed attributes;
- source and observation time;
- provenance and confidence/verification status;
- requested enrollment purpose, if supplied;
- references to supporting evidence, with secrets excluded.

Conflicting identities or insufficient evidence require review; do not merge solely on display name, IP address, filesystem path, or user-supplied label. Discovery providers are read-only with respect to enrollment and authorization.

## Authorization grant contract

A future grant record must include a stable grant ID, principal, target environment/resource, explicit capabilities, constraints, issuer/approver, creation time, expiry or documented non-expiry rationale, status, policy version, and evidence reference. Broad wildcard grants should be rejected unless a separately reviewed policy explicitly permits them. Delegation must be no broader or longer-lived than the originating grant.

Revocation must propagate to active sessions and delegated execution according to a documented, testable revocation bound. Where immediate invalidation cannot be guaranteed, the system must expose the bound and fail closed for sensitive operations.

## Memory, execution, and artifacts

- **Crystal:** durable memory, environment identity, relationships, approvals, state history, and evidence references.
- **Spark:** isolated computation; runtime identity and lifetime do not define environment identity or memory lifetime.
- **Crystal Mesh:** identity, trust, topology, relationships, and authorized interaction.
- **Veil:** isolation boundary for execution and data access.
- **PRISM:** lifecycle-governed artifacts created or used by environments.
- **Evidence:** provenance and independently verifiable transition/outcome records.
- **ATLAS:** discovery and presentation surface; display does not grant access.
- **AURA:** consistent presentation of environment identity, lifecycle, trust and authorization state.
- **FORGE:** deterministic creation of environments and associated artifacts.

These are architectural responsibilities, not claims that this manifest currently wires every subsystem together.

## Rollout

1. Validate the schema and sample manifest in CI.
2. Implement a read-only, deterministic discovery registry and candidate projection.
3. Add explicit enrollment requests and approval records.
4. Add a deny-by-default authorization evaluator and revocation semantics.
5. Integrate identity and relationships with Crystal Mesh; enforce Veil at execution.
6. Publish lifecycle/evidence projections through ATLAS without exposing secrets.
7. Test idempotency, spoofing, collisions, interrupted transitions, expiry, revocation, offline operation, recovery, and replay.
8. Certify integration only after tests and runtime evidence pass.

## Acceptance criteria

- Invalid manifests fail validation without side effects.
- Discovery never enrolls or authorizes.
- Repeated discovery produces stable identities and no duplicate grants.
- Enrollment requires attributable explicit approval.
- Unapproved or expired access is denied at the point of use.
- Revocation prevents new governed use and has a tested bound for in-flight sessions.
- Physical and non-physical environment kinds share the governance contract.
- Crystal memory remains available after a Spark is stopped or replaced.
- Lifecycle transitions produce append-only evidence without credentials or secrets.
- Rollback can disable the new zone integration without altering existing environment data.

## Current limitations

This commit defines a schema, a declarative zone instance, and architecture rules only. It does not implement a live discovery daemon, location sensing, device scanning, an enrollment UI, authorization enforcement, environment simulation, or Crystal evidence binding. Discovery source entries are configuration declarations; their operational behavior remains future work.
