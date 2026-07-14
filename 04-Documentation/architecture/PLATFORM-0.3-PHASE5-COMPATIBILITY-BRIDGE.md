# Platform 0.3 Phase 5 — Compatibility Bridge Engine

## Purpose

The Compatibility Bridge Engine distinguishes legacy root directories that intentionally preserve existing workflows from ordinary compatibility aliases.

Bridge paths are not architectural drift.

They are migration infrastructure.

## Bridge Roots

| Legacy Root | Constitutional Target |
|---|---|
| `apps` | `03-Applications` |
| `bin` | `01-Platform/cli` |
| `builder` | `01-Platform/builder` |
| `config` | `02-Infrastructure` |
| `docs` | `04-Documentation` |
| `lib` | `01-Platform/lib` |
| `services` | `02-Infrastructure/services` |
| `vault` | `05-Vault` |

## Policy

Bridge directories remain valid until:

1. compatibility wrappers exist,
2. automation is verified,
3. rollback is documented,
4. certification gates pass,
5. migration is explicitly approved.

No files are moved in this phase.
