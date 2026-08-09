# Wonderland Crystal Model

Status: FOUNDATION / IMPLEMENTATION

The Crystal Model is the next-generation Wonderland architecture. It is intentionally minimal at the core and extensible at the edge.

## Canonical primitives

| Primitive | Responsibility |
|---|---|
| Crystal | Trust, identity, mesh topology, membership, and trust roots |
| Spark | A certified capability with an explicit lifecycle and experience contract |
| Node | An execution presence for a Spark or system service |
| Veil | An isolation, security, and trust boundary |
| PRISM | A governed, lifecycle-aware artifact |
| Evidence | Verification, provenance, audit, and certification proof |
| AURA | Universal visual/interaction design language |
| ATLAS | Generic discovery and experience surface |
| FORGE | Deterministic factory for creating Sparks and their documents |

## Core invariant

No subsystem may require bespoke knowledge of a Spark to discover, certify, render, execute, observe, or retire it.

A new certified Spark should become available to ATLAS by registration and certification alone. Spark-specific presentation belongs to the Spark's experience contract, not to dashboard code.

## Core security posture

The core is deliberately small. It establishes identity, trust, capability authorization, boundaries, encryption, evidence, and lifecycle. UI, media, experimental features, and higher-level intelligence remain outside the trust root.

Security goals:

- encrypted by default
- privacy-preserving and anonymous-by-design where protocol semantics permit
- least privilege
- explicit trust boundaries
- deterministic configuration
- cryptographic identity
- revocation and recovery
- auditable state transitions
- evidence-backed certification
- no implicit network trust
- no dependency on an AI service for runtime correctness

## Lifecycle

```text
DRAFT
  -> PROPOSED
  -> BUILT
  -> VERIFIED
  -> CERTIFIED
  -> ACTIVE
  -> SUSPENDED
  -> DEPRECATED
  -> ARCHIVED
  -> OBLIVION
```

Transitions must be policy-controlled and evidence-producing.

## Naming

Canonical machine identity follows:

```text
<namespace>.<class>.<domain>.<name>.<instance>
```

Human-readable names are mutable metadata. Stable identity is immutable and must not depend on display names.

Examples:

```text
spark.intelligence.observatory.001
node.spark.matthew.001
veil.execution.oblivion.001
prism.ui.atlas.001
aura.design.system.001
forge.factory.spark.001
evidence.certificate.trust.001
```

## Factory rule

FORGE accepts the smallest useful original idea and deterministically derives the standard documents and contracts:

- identity
- manifest
- capabilities
- policy
- trust/runtime contract
- experience/UI contract
- lifecycle metadata
- documentation skeleton
- tests
- evidence requirements
- packaging metadata

Only genuinely novel decisions should require manual input. Repeated one-off decisions must become factory profiles or platform standards.

## Architecture rule

The repository should prefer contracts and generated artifacts over duplicated hand-authored integration logic. A successful exception is a candidate for standardization; it is not automatically a permanent exception.

## Migration rule

The existing Wonderland is not deleted as part of the initial transition. It becomes legacy/reference material while Crystal Model capabilities are built, verified, and migrated. Archival follows evidence-backed replacement, not aesthetic cleanup.
