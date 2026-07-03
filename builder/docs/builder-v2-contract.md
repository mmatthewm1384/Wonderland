# Builder V2 Contract

## Purpose

Builder V2 is the canonical Wonderland OS image builder runtime.

It must provide a reproducible, VM-safe, artifact-isolated build pipeline.

## Invariants

### Source / Artifact Separation

Source code lives in the repository.

Generated artifacts must not be written to the repository.

All generated build output belongs under:

```text
${WONDERLAND_BUILD_ROOT}
If unset, the default is:

~/Wonderland-Builds
Supported Entry Point

The supported entry point is:

bin/wl builder <command>

Direct unmanaged execution is unsupported on macOS.

Stage Interface

Every stage must implement:

run(context: BuilderContext) -> StageResult

Stages must not call other stages directly.

Context Authority

Every stage receives one BuilderContext.

Stages must use context-provided paths and must not reconstruct repository-relative artifact paths independently.

Artifact Authority

Build artifacts are represented through a shared artifact model.

Required artifact fields:

raw_image
qcow2_image
manifest
mount_root
loop_device
root_partition
efi_partition
Pipeline Ownership

The runtime owns stage order.

Target order:

disk
mount
bootstrap
packages
identity
locale
users
networking
bootloader
verify-image
cleanup
convert
manifest
Cleanup Requirement

Cleanup must be idempotent.

It must be safe after:

successful builds
failed builds
repeated partial builds
stale loop devices
stacked mounts

A successful build must leave no mounted filesystems under WONDERLAND_BUILD_ROOT.

Success Criteria

A stable Builder V2 baseline requires:

bin/wl builder doctor
bin/wl builder build --profile development
mount | grep Wonderland-Builds || true
sudo losetup -a | grep Wonderland-Builds || true
bin/wl builder artifacts

Expected:

doctor passes
build completes
artifacts are under WONDERLAND_BUILD_ROOT
no lingering mounts
no lingering loop devices
repository remains free of generated artifacts
