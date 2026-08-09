# FORGE — Spark Factory Specification

Status: FOUNDATION / IMPLEMENTATION

FORGE is the deterministic creation layer for the Crystal Model. It converts a small original idea into a complete, reviewable Spark package without requiring the author to repeatedly make the same structural decisions.

## Design goal

Input should be small:

```yaml
id: observatory
name: Intelligence Observatory
class: intelligence
purpose: Observe, correlate, and explain Wonderland state.
```

Output should be complete enough to build, verify, certify, render, execute, observe, recover, and retire the Spark.

## Factory pipeline

```text
IDEA
  -> NORMALIZE
  -> VALIDATE
  -> RESOLVE PROFILE
  -> GENERATE CONTRACTS
  -> GENERATE EXPERIENCE SHELL
  -> GENERATE TESTS
  -> GENERATE EVIDENCE PLAN
  -> VERIFY
  -> READY FOR CERTIFICATION
```

FORGE does not certify the resulting Spark. Certification remains a separate trust decision.

## Generated package

```text
sparks/<spark-id>/
├── spark.yaml
├── identity.yaml
├── capabilities.yaml
├── policy.yaml
├── runtime.yaml
├── experience.yaml
├── lifecycle.yaml
├── evidence.yaml
├── README.md
├── tests/
│   └── contract_test.py
└── ui/
    └── manifest.yaml
```

The exact implementation directory may evolve, but the logical contracts are stable.

## Required fields

The author supplies only:

- stable Spark identifier
- human name
- class
- purpose

Optional fields may override a factory profile when a genuine new requirement exists.

The factory supplies defaults for:

- versioning
- lifecycle
- trust boundary
- capability declaration structure
- evidence requirements
- UI/experience contract
- documentation
- test skeleton
- packaging metadata

## Override rule

Overrides must be explicit and local. A one-off override is evidence that the factory profile or platform standard may need improvement.

No generated artifact may silently inherit an unsafe default.

## Determinism

Given the same normalized idea, factory profile, and factory version, FORGE must produce equivalent output.

The generated package records:

- factory version
- profile version
- generation timestamp
- source idea hash
- generated artifact hashes

Timestamps must not affect semantic identity or verification.

## Trust boundary

FORGE is a build-time tool. It is not part of the Crystal trust root and must not gain runtime authority merely because it generated an artifact.

A generated Spark becomes trusted only after independent verification and certification.

## Failure policy

FORGE must fail closed when:

- the identifier is invalid
- a required field is missing
- an override violates a contract
- a generated path would escape the target package
- a profile is missing or malformed
- generated output conflicts with an existing package

FORGE must never overwrite an existing certified Spark without an explicit migration operation.
