# Import Quarantine Policy

## Purpose

Prevent unsafe legacy artifacts from being promoted into Wonderland-v4 active domains.

## Quarantined Artifacts

The following must not be promoted directly:

- Private keys
- Certificates
- Secret keys
- Password files
- Live database files
- Runtime data directories
- Poisoned infrastructure state
- Binary installers
- Unknown executable files

## Known Quarantine Areas

- Harbor poisoned state
- Harbor database files
- Recovered private keys
- Recovered certificates
- Legacy runtime data

## Promotion Requirement

Any quarantined artifact requires:

1. Review
2. Classification
3. Sanitization
4. Replacement or rotation
5. Documented approval

## Recovery

Quarantined material remains in the legacy archive unless explicitly sanitized.

## Rollback

Remove promoted copy and return to archive-only status.
