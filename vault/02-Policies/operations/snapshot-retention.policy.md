# Snapshot Retention Policy
<!-- id: snapshot-retention-policy-v4 -->

## Rule

Vault snapshots must be retained long enough to support rollback while preventing uncontrolled storage growth.

## Default Retention

Keep the newest 20 vault snapshots.

## Pruning Rule

Only prune snapshots after:

- Vault verification passes
- Snapshot checksums exist
- Operator invokes pruning explicitly

## Status

state: active
version: 4
