# Engine Registry

## Purpose

The Engine Registry defines the highest-level architectural objects in Wonderland.

The platform hierarchy is:

```text
Platform
  ↓
Engine
  ↓
Domain
  ↓
Capability
  ↓
Component
  ↓
Implementation
  ↓
Files
Why Engines Exist

Engines prevent overlapping responsibilities.

Every major platform responsibility belongs to one engine. Capabilities, components, implementations, documentation, certification, and Academy lessons all trace back to that engine.

Registry Rule

The Registry Engine is the only subsystem that parses architecture/engines.yaml.

Other engines consume the Registry Engine API.

Explain It Test

The operator should be able to explain:

Why engines exist.
Which engine owns a capability.
Why dependency cycles are forbidden.
Why the Registry Engine is the source of truth.
How engines make Wonderland easier to understand and teach.
