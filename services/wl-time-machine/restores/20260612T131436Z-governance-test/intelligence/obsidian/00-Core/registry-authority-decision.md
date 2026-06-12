# Registry Authority Decision

## Decision

Governance.md is authoritative.

.wl-registry is generated.

## Authority Chain

```text
~/Wonderland/intelligence/obsidian/00-Core/Governance.md
        ↓
wl-governance sync / generate
        ↓
~/Wonderland/.wl-registry

Rules
Governance.md is the source of truth.
.wl-registry is generated runtime state.
.wl-registry must not redefine governance.
.wl-registry may cache paths, commands, services, ports, networks, volumes, and runtime status.
If Governance.md and .wl-registry conflict, Governance.md wins.
Regenerate .wl-registry from governance rather than editing it manually.
Operational Principle
Policy drives runtime.
Runtime does not redefine policy.
