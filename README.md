# Wonderland Platform Architecture

Sovereign local-first engineering platform and distributed memory system. Built for deterministic, isolated compute execution and cryptographic state control across local nodes and peer networks.

---

## Core System Primitives

| Primitive | Classification | Description |
| :--- | :--- | :--- |
| **Crystal** | Persistent Memory | Immutable state logging, snapshotting, and long-term memory retrieval. |
| **Spark** | Compute Engine | Ephemeral, isolated micro-VM sandboxes (`debian:bookworm-slim` arm64) powered by `vfkit`. |
| **Crystal Mesh** | Mesh Network | Cryptographic identity, zero-trust access control, and P2P state synchronization via Tailscale. |
| **Node** | Host Environment | Host runtime orchestration running on macOS (Apple Silicon). |
| **Veil** | Volatile Isolation | Teardown-enforced RAM disk runtime sandbox protecting execution data. |
| **PRISM** | Artifact Lifecycle | Lifecycle-aware artifact versioning and verification packaging. |
| **FORGE** | Build Factory | Multi-toolchain automated build factory (Rust, Python, C, Swift). |
| **ATLAS** | Discovery Surface | Platform metadata indexer and discovery surface across nodes. |
| **AURA** | Design System | High-contrast visual interface system (`#B00040` primary accent). |

---

## Repository Structure

/Users/Wonderland/wonderland/
├── bin/
│   └── wonderland           # Daemonless control plane CLI wrapper
├── scripts/                 # System automation, telemetry, and execution hooks
├── var/                     # Ephemeral runtime state and logs (ignored by Git)
├── .gitignore               # Excludes secrets (.env), logs, and virtual environments
└── README.md                # System architectural reference


---

## Operational Workflows

### 1. Execute Control Plane CLI
```zsh
./bin/wonderland status
2. Verify Ignored Artifacts
Ensure temporary runtimes and environment secrets remain un-tracked:

Bash
git status --ignored
