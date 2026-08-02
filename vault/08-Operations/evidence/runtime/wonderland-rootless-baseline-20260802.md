# Wonderland Rootless Runtime Baseline

Date:
2026-08-02

## Runtime

Name:
wonderland-rootless

Platform:
Lima

OS:
Ubuntu

Architecture:
aarch64

Kernel:
7.0.0-28-generic

User:
wonderland

UID:
501

## Runtime Status

Rootless container runtime:
Enabled

VM Type:
vz

Purpose:
Development runtime baseline before Debian runtime migration.

## Known Issues

- Guest shell attempts to enter /Users/wonderland/Wonderland
- Host path does not exist inside guest
- Runtime contains accumulated development state

## Migration Target

wonderland-debian-rootless-v1

Goals:

- reproducible build
- minimal Debian base
- rootless runtime
- certified configuration
- rollback capability
