# Wonderland Lima Hardened Baseline

Version:
1.0

Purpose:

Canonical Lima runtime boundary for Wonderland.

## Design Goals

- Host isolation
- Rootless container execution
- Controlled filesystem exposure
- Recoverable VM lifecycle
- Observable runtime state

## Required Properties

| Property | Required |
|---|---|
| vmType | vz |
| CPU | 4 |
| Memory | >=8GiB |
| Disk | >=100GiB |
| Mounts | /mnt/shared only |
| Containerd | rootless |
| Network | user mode |
| SSH | localhost only |

## Validation

The instance must pass:

- mount verification
- nerdctl rootless verification
- AppArmor verification
- resource verification
