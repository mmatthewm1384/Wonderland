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

## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
