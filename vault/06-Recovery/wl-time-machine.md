# wl-time-machine

Purpose:
- Append-only snapshots
- Manifest verification
- Staged restore
- Recovery bundle generation

Safety:
- Never restores directly into live data
- Restore is always staged first
- Snapshots are immutable once created
