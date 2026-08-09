# Spark Mesh Specification

Status: FOUNDATION / IMPLEMENTATION

Spark Mesh is the Crystal networking and discovery model. It is a logical trust mesh, not a requirement for a flat or globally reachable network.

## Purpose

Spark Mesh provides a common way for certified Sparks and Nodes to:

- identify themselves
- discover permitted peers and capabilities
- establish authenticated channels
- exchange signed capability metadata
- publish health and lifecycle state
- revoke or quarantine compromised members

## Core rule

**Discovery does not imply trust.**

A peer may be visible to the mesh while remaining unauthorized for execution, data access, or control.

## Layers

```text
Crystal
  └── Trust Root
       ├── Identity
       ├── Membership
       └── Revocation

Spark Mesh
  ├── Discovery
  ├── Capability Advertisement
  ├── Authenticated Session
  ├── Policy Evaluation
  └── Evidence

Spark
  └── Execution / Experience
```

## Membership states

```text
UNKNOWN -> OBSERVED -> ATTESTED -> TRUSTED -> SUSPENDED -> REVOKED
```

Only policy may promote a member to TRUSTED.

## Required peer properties

Every mesh member has:

- stable cryptographic identity
- node identity
- Spark identity when applicable
- trust state
- capability advertisement
- protocol version
- revocation status
- evidence reference

Human-readable names are never authoritative for membership.

## Network posture

Default posture is deny-by-default.

The mesh may operate over:

- local Unix sockets
- loopback
- isolated VM networks
- private LANs
- encrypted overlay networks
- explicitly authorized external transports

The transport is replaceable. The trust protocol is not coupled to a particular network topology.

## Privacy

Anonymous-by-design means minimizing unnecessary disclosure, not pretending that authenticated systems have no identity. Peer identity should be disclosed only to the minimum parties required by policy.

## Failure behavior

A node that loses trust connectivity must degrade safely:

- no implicit trust promotion
- no fallback to unauthenticated control
- cached state marked stale
- privileged operations blocked when required evidence is unavailable
- recovery performed through explicit re-attestation

## Mesh and ATLAS

ATLAS consumes certified Spark metadata from the mesh registry. ATLAS must not contain Spark-specific routing logic.

Adding a certified Spark therefore follows:

```text
FORGE -> VERIFY -> CERTIFY -> MESH REGISTRATION -> ATLAS DISCOVERY
```

No dashboard modification is required for ordinary Sparks.
