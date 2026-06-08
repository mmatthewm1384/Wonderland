# Change Management
<!-- id: change-management-v4 -->

## Purpose

Define how Wonderland core changes are proposed, applied, verified, and rolled back.

## Change Flow

1. Propose
2. Review
3. Backup
4. Apply
5. Verify
6. Commit
7. Document rollback

## Protected Changes

Changes to protected paths require review before commit.

Protected paths are defined in:

```text
metadata/protected-paths.json
Failure Rule

If verification fails, the change must be reverted or isolated before further promotion.

Status

state: active
version: 4
