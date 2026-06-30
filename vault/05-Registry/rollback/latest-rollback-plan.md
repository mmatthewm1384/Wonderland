# Wonderland Rollback Plan

**Generated:** 2026-06-30T02:08:37Z

## Source of Truth

- Latest checkpoint: vault/05-Registry/checkpoints/latest-platform-core.json
- Certification: vault/05-Registry/certifications/platform-core-2.3.json

## Validation

```bash
wl checkpoint validate
wl status
wl doctor all
wl verify
```

## Manual Recovery Strategy

1. Inspect the latest certified checkpoint.
2. Compare current status with the checkpoint status artifacts.
3. Restore from Git first if source files changed.
4. Regenerate derived artifacts with safe fix.
5. Re-run doctor and verify.

## Safe Recovery Commands

```bash
git status --short
wl checkpoint latest
wl checkpoint validate
wl fix apply --safe
wl doctor all
wl verify
```

## Explicitly Not Automated

- No source overwrite
- No release promotion
- No deletion
- No governance mutation
- No external disk assumptions
