# Tier 1 Technical Standard: Container Runtime Engine

## Core Specification
Wonderland mandates a fully decoupled, rootless container runtime infrastructure to limit host-level exploitation surfaces and remove legacy monolithic dependencies.

## Runtime Boundary Configuration
* **Engine:** `nerdctl` (General command line interface tool)
* **Subsystem Daemon:** `containerd`
* **Privilege Level:** Non-root (Rootless mode execution)
* **Architecture Target:** Apple Silicon (ARM64 Optimized)

## Storage and Communication Bounds
All inter-container operational networking loops must bypass default bridges and connect strictly using unprivileged, isolated virtual networks or verified unix socket descriptors.
