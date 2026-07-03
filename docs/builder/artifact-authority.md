# Builder v2 Artifact Authority

Builder v2 canonical artifacts live under:

```text
builder/output/
```

List artifacts with:

```bash
wl builder artifacts
```

The builder creates or collects build outputs into `builder/output/`.

The release subsystem should publish from `builder/output/`, not directly from legacy build locations.

## Current Artifacts

- `builder/output/manifests/wonderland-os-0.1.1-arm64-development.manifest.json`
- `builder/output/qcow2/wonderland-os-0.1.1-arm64-development.qcow2`
- `builder/output/raw/wonderland-os-0.1.1-arm64-development.raw`
- `builder/output/tmp/native-stages.json`
