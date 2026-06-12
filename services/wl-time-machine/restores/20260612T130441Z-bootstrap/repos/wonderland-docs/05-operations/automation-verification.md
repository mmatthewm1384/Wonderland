---
title: Automation Verification
type: operations
status: draft
version: 1.0.0
parent: "[[automation-foundation]]"
tags:
  - operations
  - automation
  - verification
---

# Automation Verification

## Baseline Checks

```shell
wl-status
wl-verify
wl-init --help
wl-backup --help
wl-recover --help
wl-export --help
```

## Expected Result

All commands should return usable output and exit successfully.

## Failure Handling

If commands are unavailable:

1. Confirm `~/Wonderland/tools/bin` exists.
2. Confirm it is in `PATH`.
3. Re-run `04-automation/wl/install.sh`.
4. Use manual procedures if command recovery fails.
