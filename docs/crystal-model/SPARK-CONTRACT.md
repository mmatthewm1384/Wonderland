# Spark Contract v0.1

A Spark is a certified capability, not a UI page, process, or VM image.

## Required identity

```yaml
identity:
  id: spark.<class>.<domain>.<name>.<instance>
  version: <semantic-version>
  contract: spark/v0.1
```

## Required sections

```yaml
spark:
  identity: {}
  purpose: {}
  capabilities: []
  dependencies: []
  security: {}
  runtime: {}
  experience: {}
  lifecycle: {}
  evidence: {}
  certification: {}
```

## Capabilities

Every executable capability must have:

- stable capability identifier
- explicit input/output contract
- authorization requirement
- trust boundary
- side-effect classification
- observability events
- evidence requirements

## Experience contract

The Spark owns its presentation metadata. ATLAS consumes this contract generically.

The experience contract may describe:

- icon/mark
- title and description
- navigation placement
- supported views
- actions
- telemetry cards
- status indicators
- required assets
- responsive behavior
- accessibility metadata

The dashboard must not contain Spark-specific branching such as `if spark == ...`.

## Certification

A Spark is not ACTIVE merely because its files exist. Certification requires verification of its declared contract and generation of evidence. Certification must be revocable.

## Compatibility

A contract version change must identify whether it is:

- backward compatible
- migration-required
- incompatible

Runtime behavior must never silently reinterpret an incompatible contract.
