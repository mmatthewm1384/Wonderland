# Wonderland Mirror Engine

Mirror Engine 1.0 provides a stable control plane around Wonderland's existing
mirror operations.

## Structural commands

```text
wl mirror doctor
wl mirror verify
wl mirror certify
wl mirror status
Operational commands
wl mirror snapshot
wl mirror diff
wl mirror restore
wl mirror repair
wl mirror sync

Operational commands delegate to the preserved legacy Mirror implementation.
Verification and certification never start a synchronization or restore.
