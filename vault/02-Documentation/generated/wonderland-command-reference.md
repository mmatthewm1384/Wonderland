# Wonderland Command Reference

Generated: 2026-06-29 07:22:52

Runtime:

- Version: 2.0.0
- Build: 20260628
- Profile: internal-light
- Mode: light

## Commands

| Path | Language | Lint |
|---|---|---|
| `bin/wl` | `bash` | `yes` |
| `bin/wl-start` | `bash` | `yes` |
| `bin/wl-doctor` | `bash` | `yes` |
| `bin/wl-runtime` | `bash` | `yes` |
| `bin/wl-services` | `bash` | `yes` |
| `bin/wl-storage` | `bash` | `yes` |
| `bin/wl-profile` | `bash` | `yes` |
| `bin/wl-capability` | `bash` | `yes` |
| `bin/wl-status` | `bash` | `yes` |
| `bin/wl-api` | `bash` | `yes` |
| `bin/wl-test` | `bash` | `yes` |
| `bin/wl-lint` | `bash` | `yes` |
| `bin/wl-lifecycle-report` | `bash` | `yes` |
| `bin/wl-universe` | `bash` | `yes` |
| `bin/wl-chaos-schedule` | `python` | `yes` |
| `bin/wl-chaos-schedule-run` | `python` | `yes` |
| `bin/wl-chaos-schedule-eval` | `python` | `yes` |
| `bin/wl-chaos-policy` | `python` | `yes` |
| `bin/wl-shell-repair` | `python` | `yes` |
| `bin/wl-context` | `bash` | `yes` |
| `bin/wl-state` | `bash` | `yes` |
| `bin/wl-verify` | `bash` | `yes` |
| `bin/wl-certify` | `bash` | `yes` |
| `bin/wl-release` | `bash` | `yes` |
| `bin/wl-docs` | `bash` | `yes` |
| `bin/wl-baseline` | `bash` | `yes` |
| `bin/wl-handoff` | `bash` | `yes` |
| `bin/wl-release-validate` | `bash` | `yes` |
| `bin/wl-checkpoint` | `bash` | `yes` |
| `bin/wl-boot` | `bash` | `yes` |

## Core Libraries

| Path | Language | Lint |
|---|---|---|
| `lib/wl-bootstrap.sh` | `bash` | `yes` |
| `lib/wl-lib.sh` | `bash` | `yes` |
| `lib/wl-dispatch.sh` | `bash` | `yes` |
| `lib/wl-runtime.sh` | `bash` | `yes` |
| `lib/wl-services.sh` | `bash` | `yes` |
| `lib/wl-storage.sh` | `bash` | `yes` |
| `lib/wl-profile.sh` | `bash` | `yes` |
| `lib/wl-capability.sh` | `bash` | `yes` |
| `lib/wl-json.sh` | `bash` | `yes` |
| `lib/wl-context.sh` | `bash` | `yes` |
| `lib/wl-context-validate.py` | `python` | `yes` |
| `lib/core/load.sh` | `bash` | `yes` |
| `lib/core/health.sh` | `bash` | `yes` |
| `lib/core/context.sh` | `bash` | `yes` |
| `lib/core/json.sh` | `bash` | `yes` |
| `lib/core/runtime.sh` | `bash` | `yes` |
| `lib/core/services.sh` | `bash` | `yes` |
| `lib/core/storage.sh` | `bash` | `yes` |
| `lib/core/capability.sh` | `bash` | `yes` |
| `lib/core/profile.sh` | `bash` | `yes` |
| `lib/core/health-v2.sh` | `bash` | `yes` |
| `lib/core/state.sh` | `bash` | `yes` |
| `lib/core/health-state.sh` | `bash` | `yes` |
| `lib/core/runtime-object-validate.py` | `python` | `yes` |

## Machine-Readable Interfaces

| Command | Schema / Output |
|---|---|
| `wl api status` | `wonderland.api.status.v2` |
| `wl status --json` | Delegates to `wl api status` |
| `wl doctor --json` | `wonderland.doctor.v1` |
| `wl universe status --json` | `wonderland.universe.status.v1` |
| `wl runtime status --json` | Runtime status object |
| `wl services status --json` | Service status object |
| `wl storage status --json` | Storage status object |
| `wl profile status --json` | Profile status object |
| `wl capability status --json` | Capability status object |

## Runtime Objects

| Object | Path |
|---|---|
| Context | `runtime/context.json` |
| State | `runtime/state.json` |
| Capabilities | `runtime/capabilities.json` |
| Health | `runtime/health.json` |
