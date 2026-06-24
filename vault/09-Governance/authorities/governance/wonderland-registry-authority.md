# wonderland-registry-authority.md

# Wonderland Registry Authority (WRegA)

## Purpose

Defines how registries are created, maintained, verified, versioned, recovered, and certified throughout Wonderland.

A registry is the authoritative machine-readable representation of a governed system.

## Scope

Applies to:

* Governance registries
* Certification registries
* Recovery registries
* Service registries
* Authority registries
* Asset registries
* Metadata registries

## Authority Hierarchy

Code: WRegA

Parent: WGA

Layer: Registry Governance

Status: Certified

Version: 1.0

## Context Model

Authorities govern meaning.

Registries govern machine-readable truth.

Every governed Wonderland system must have a corresponding registry.

## Registry Principles

Registries must be:

* Persistent
* Recoverable
* Auditable
* Versioned
* Machine-readable

## Registry Standards

Preferred format:

```text
JSON
```

Allowed formats:

```text
JSON
YAML
```

## Required Registry Fields

```json
{
  "id": "",
  "type": "",
  "status": "",
  "version": "",
  "created": "",
  "updated": ""
}
```

## Registry Categories

### Governance

```text
governance-registry.json
ownership-registry.json
policy-registry.json
```

### Certification

```text
certification-registry.json
```

### Recovery

```text
recovery-registry.json
```

### Services

```text
service-registry.json
```

### Assets

```text
asset-registry.json
```

## Verification

```bash
wl-authorities context
```

## Recovery

Restore registry backups and verify integrity.

## Rollback

Restore previous certified registry version.

## Certification

PASS registry-schema

PASS registry-versioning

PASS registry-recovery

PASS registry-governance

PASS authority-context

RESULT PASS

## Machine Readable Status

```yaml
authority:
  code: WRegA
  parent: WGA
  layer: Registry Governance
  status: certified
  result: PASS
```

RESULT PASS
