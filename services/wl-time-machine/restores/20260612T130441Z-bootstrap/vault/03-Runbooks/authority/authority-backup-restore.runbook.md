# Authority Backup Restore Runbook

## Purpose

Restore Wonderland authority from a verified T7 persistence backup.

## Authority Root

```text
/Users/wonderland/Wonderland
Persistence Backup Root
/Volumes/T7_Wonderland/Wonderland/persistence/backups/authority
Backup
wl authority backup
Verify Backup
wl authority verify-backup
Restore Drill
wl authority restore-drill
Full Doctor
wl doctor
Manual Recovery Procedure
Mount T7.
Locate latest authority backup.
Verify manifest.
Restore into a clean Wonderland root.
Run wl doctor.
Principle

Runtime state is disposable.
Authority is not.
