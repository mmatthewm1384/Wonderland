# Tier 1 Technical Standard: Micro-VM Isolation Boundaries

## 1. Boundary Enforcements
* **Hardware Virtualization:** All compute tasks must execute within a hardware-accelerated, kernel-backed Micro-VM.
* **Kernel Separation:** Workloads shall not share the host macOS kernel. Every Micro-VM must boot a distinct, minimalist, read-only guest kernel.
* **Memory Entitlements:** Memory allocated to a Micro-VM must be pinned and statically assigned at boot to prevent dynamic memory allocation side-channel attacks.

## 2. Peripheral & Device Isolation
* **Storage Blocks:** Guest filesystems must use separate, encrypted disk image blocks (`.raw` or `.qcow2`). No direct host directory bind-mounts are permitted unless explicitly read-only.
* **Network Enclosure:** Micro-VMs must utilize isolated network taps (`vtnet`) with no direct access to the host loopback device (`127.0.0.1`). All traffic must route through a dedicated software switch.
