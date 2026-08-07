# Veil-01

Veil-01 is Wonderland's canonical architecture for a resilient private habitat.

## Current implementation state

**Architecture baseline + system model + failure model + capability contract.**

Canonical artifacts:

- `veil-01.yaml` — architectural baseline
- `system-model.yaml` — subsystem, dependency, and interface model
- `failure-modes.yaml` — critical failure and recovery behaviors
- `capability-contract.yaml` — authorization boundary for physical actuation

## Objective

Preserve human life, autonomy, privacy, capability, and quality of life across prolonged disruption while remaining a normal, beautiful home during ordinary operation.

## Architectural model

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

The service layer is separated from primary living spaces so infrastructure can be inspected, maintained, isolated, or replaced without unnecessarily disturbing habitation.

## System model

Critical domains are explicitly modeled rather than treated as an undifferentiated smart-home system:

```text
                  ┌───────────────┐
                  │  OBSERVABILITY │
                  └───────┬───────┘
                          │
             ┌────────────┴────────────┐
             │       COMPUTING         │
             └────────────┬────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
      ENERGY            AIR              WATER
        │                 │                 │
        └────────────┬────┴────┬────────────┘
                     │         │
              PHYSICAL ACCESS  │
                     │         │
                  SANCTUARY  FABRICATION
```

This is a logical dependency model, not a physical wiring diagram.

## Critical systems

- **Energy:** generation → storage → distribution, with islandable operation.
- **Water:** source → raw storage → treatment → potable storage → distribution.
- **Air:** controlled ventilation, filtration, humidity, smoke, and radon management.
- **Communications:** local-first operation with external connectivity treated as optional.
- **Computing:** edge-first local services, storage, automation, telemetry, and evidence.
- **Physical access:** explicit authorization, life-safety handling, and manual override.
- **Fabrication:** repair and small-scale manufacturing capability.
- **Storage:** critical spares, tools, consumables, food, water, and emergency equipment.

## Operating modes

| Mode | Purpose |
|---|---|
| `normal` | Full residential operation |
| `conservation` | Reduced resource consumption |
| `isolated` | External infrastructure unavailable |
| `emergency` | Life-safety preservation |
| `recovery` | Controlled restoration and verification |

Transitions are attributable, timestamped, verified, and represented in evidence.

## Failure model

Veil-01 explicitly models grid loss, smoke events, water-source loss, communications loss, computing degradation, enclosure compromise, and multi-system events.

Recovery follows:

```text
ISOLATE → RESTORE → VERIFY → REINTEGRATE
```

A failed subsystem is never simply switched back on because it appears available. Its configuration, dependencies, health, and functional behavior must be verified first.

## Trust and capability model

No critical domain implicitly trusts every other domain.

Physical actuation requires, by default:

1. authenticated identity
2. explicit capability
3. policy authorization
4. operating-mode compatibility
5. audit evidence

The default posture is **deny by default**. Loss of network connectivity must not create new authority. Loss of policy services fails closed except for explicitly defined life-safety paths.

## Wonderland integration

Veil-01 is intended to consume Wonderland's governance and capability foundations rather than create a parallel control plane. Relevant boundaries include:

- Identity
- Trust Foundation
- Capability Registry
- Evidence System
- Transaction Engine
- Oblivion

The physical environment remains subordinate to explicit capabilities and governance policy; physical actuation is never an ambient permission.

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

## Important boundary

These artifacts specify the **digital/system architecture**. They do not constitute structural engineering, geotechnical engineering, electrical engineering, mechanical engineering, plumbing design, fire-code certification, permitting, or construction documents.

Those disciplines become subsequent implementation packages with their own assumptions, calculations, responsible professionals, verification evidence, and approval gates.
