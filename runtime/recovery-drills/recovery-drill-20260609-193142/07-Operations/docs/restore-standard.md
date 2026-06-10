# Restore Standard
<!-- id: restore-standard-v4 -->

Purpose:
Defines how Wonderland restores from a vault snapshot.

Restore command:
    wl restore <snapshot.tar.gz>

Requirements:

- Verify snapshot checksum before restore
- Create pre-restore backup
- Restore files
- Run verification
- Record restore evidence

Failure rule:
If restore verification fails, use the pre-restore backup.

state: active
version: 4
