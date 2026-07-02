# Builder v2 Runtime

## Status

Builder v2 now has a single supported runtime entry path:

```text
wl builder
  -> python3 -m wlbuilder
  -> builder/python/wlbuilder/runtime.py
The legacy implementation remains temporarily available through:

build.__main__
Supported Commands
wl builder verify
wl builder doctor
wl builder certify
wl builder build --profile development

Runtime-level commands:

python3 -m wlbuilder status
python3 -m wlbuilder verify
python3 -m wlbuilder doctor
python3 -m wlbuilder build --profile development
Current Architecture
builder/
  config.yaml
  python/
    wlbuilder/
      runtime.py
      cli.py
      config.py
      context.py
      stages.py
      artifacts.py
      doctor.py
      verify.py
  output/
    raw/
    qcow2/
    vmware/
    logs/
    manifests/
    cache/
    tmp/
Validation Gates

Fast contract check:

wl builder verify

Full local/runtime check:

wl builder doctor

Certification gate:

wl builder certify

Smoke test:

bin/wl-builder-smoke
Remaining Work
Move orchestration out of build.__main__.
Convert legacy image generation into explicit stages.
Standardize all generated artifacts under builder/output/.
Validate full build, publish, VM boot, SSH, and wl doctor all.
Remove images/build-qcow2.py after compatibility window.
Remove legacy bridge after Builder v2 can produce a certified bootable image.
