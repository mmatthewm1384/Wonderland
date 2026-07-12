# Builder v2 Artifact Authority

Builder v2 canonical artifacts live under:

```text
/home/wonderland.guest/Wonderland-Builds/
```

List artifacts with:

```bash
wl builder artifacts
```

The builder creates or collects build outputs into `$WONDERLAND_BUILD_ROOT/`.

The release subsystem should publish from `$WONDERLAND_BUILD_ROOT/`, not directly from legacy build locations.

No artifacts currently present.
