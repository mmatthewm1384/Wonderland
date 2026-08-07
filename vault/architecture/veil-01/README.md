# Veil-01

Veil-01 is Wonderland's canonical architecture baseline for a resilient private habitat.

## Objective

Preserve human life, autonomy, privacy, capability, and quality of life across prolonged disruption while remaining a normal, beautiful home during ordinary operation.

## Architectural model

Veil-01 is layered rather than bunker-centric:

```text
LANDSCAPE
    ↓
SITE
    ↓
PROTECTIVE ENVELOPE
    ↓
SERVICE / UTILITY LAYER
    ↓
ENVIRONMENTAL LAYER
    ↓
SANCTUARY
```

The service layer is intentionally separated from primary living spaces so infrastructure can be inspected, maintained, isolated, or replaced without unnecessarily disturbing habitation.

## Critical systems

- Energy: generation → storage → distribution, with islandable operation.
- Water: source → raw storage → treatment → potable storage → distribution.
- Air: controlled ventilation, filtration, humidity, smoke, and radon management.
- Communications: local-first operation with external connectivity treated as optional.
- Computing: edge-first local services, storage, automation, telemetry, and evidence.
- Fabrication: repair and small-scale manufacturing capability.
- Storage: critical spares, tools, consumables, food, water, and emergency equipment.

## Operating modes

| Mode | Purpose |
|---|---|
| `normal` | Full residential operation |
| `conservation` | Reduced resource consumption |
| `isolated` | External infrastructure unavailable |
| `emergency` | Life-safety preservation |
| `recovery` | Controlled restoration and verification |

Every transition is intended to be attributable, timestamped, verified, and represented in evidence.

## Trust model

No critical domain is permitted to implicitly trust every other domain. Critical systems are separated into explicit trust boundaries with least-privilege control, local fallback, and manual life-safety override.

## Wonderland integration

Veil-01 is intended to integrate with Wonderland's existing governance and capability architecture rather than create a parallel control plane. Relevant boundaries include:

- Identity
- Trust Foundation
- Capability Registry
- Evidence System
- Transaction Engine
- Oblivion

The physical environment remains subordinate to explicit digital capabilities and governance policy; physical actuation is never treated as an ambient permission.

## Lifecycle

```text
CONCEPT
  → SITE VALIDATION
  → SCHEMATIC DESIGN
  → ENGINEERING
  → CONSTRUCTION
  → COMMISSIONING
  → CERTIFIED OPERATION
  → MAINTENANCE
  → RENEWAL
  → RETIREMENT
```

No lifecycle stage is considered complete without evidence.

## Current state

`architecture-baseline / 0.1.0`

This artifact establishes the architecture. It does not claim that a physical site, structural design, utility design, or code-compliant construction package has been completed.
