# Builder v2 Stage Migration

This document is generated from the live Builder v2 stage registry.

Regenerate with:

```bash
wl builder docs
```

| Stage | Mode | Implemented | Ready | Legacy Source | Responsibility |
|---|---|---|---|---|---|
| `disk` | native | true | true | build.__main__ stage 02 Disk | Create raw disk image and partition layout. |
| `mount` | native | true | true | build.__main__ stage 03 Mount | Attach image, create filesystems, and mount root/EFI filesystems. |
| `bootstrap` | legacy | true | true | build.__main__ bootstrap stage | Bootstrap Debian root filesystem. |
| `packages` | native | true | true | build.__main__ packages stage | Install base Wonderland OS packages into the bootstrapped root filesystem. |
| `identity` | native | true | true | build.__main__ identity stage | Configure system hostname and hosts file. |
| `locale` | native | true | true | build.__main__ locale stage | Configure locale, timezone, and keyboard defaults. |
| `users` | native | true | true | build.__main__ users stage | Create default Wonderland user and sudo access. |
| `networking` | native | true | true | build.__main__ networking stage | Configure basic DHCP networking and SSH. |
| `bootloader` | native | true | true | build.__main__ bootloader stage | Install GRUB EFI bootloader into the mounted image. |
| `verify-image` | native | true | true | native verify-image | Verify boot-critical image contents. |
| `cleanup` | native | true | true | native cleanup | Unmount image filesystems and detach loop devices. |
| `convert` | native | true | true | native convert | Convert raw image into QCOW2 artifact and generate checksums. |
| `manifest` | native | true | true | native manifest | Generate build manifest from native artifact authority. |
