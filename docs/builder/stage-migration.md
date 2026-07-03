# Builder v2 Stage Migration

This document is generated from the live Builder v2 stage registry.

Regenerate with:

```bash
python3 -m wlbuilder docs
```

| Stage | Mode | Implemented | Ready | Legacy Source | Responsibility |
|---|---|---|---|---|---|
| `disk` | legacy | true | true | build.__main__ stage 02 Disk | Create raw disk image and partition layout. |
| `mount` | legacy | false | true | build.__main__ stage 03 Mount | Attach image, mount filesystems, and prepare chroot. |
| `bootstrap` | legacy | false | true | build.__main__ stage 04 Bootstrap | Install Debian base system. |
| `packages` | legacy | false | true | build.__main__ stage 05 Packages | Install kernel, bootloader, SSH, and base packages. |
| `identity` | legacy | false | true | build.__main__ stage 06 Identity | Configure hostname, branding, os-release, and MOTD. |
| `locale` | legacy | false | true | build.__main__ stage 07 Locale | Configure UTF-8 locale. |
| `users` | legacy | false | true | build.__main__ stage 08 Users | Create default user and sudo policy. |
| `networking` | legacy | false | true | build.__main__ stage 09 Networking | Configure SSH, Chrony, Avahi, resolved, and networking. |
| `bootloader` | legacy | false | true | build.__main__ stage 10 Bootloader | Install EFI bootloader and GRUB. |
| `verify-image` | legacy | false | true | build.__main__ stage 11 Verify | Verify boot-critical image contents. |
| `cleanup` | legacy | false | true | build.__main__ stage 12 Cleanup | Unmount filesystems and detach loop devices. |
| `convert` | legacy | false | true | build.__main__ stage 13 Convert | Convert raw image into qcow2/vmdk artifacts. |
| `manifest` | legacy | false | true | build.__main__ stage 14 Manifest | Generate build manifest. |
