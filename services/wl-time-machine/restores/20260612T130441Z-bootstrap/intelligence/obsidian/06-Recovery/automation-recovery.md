---
title: Automation Recovery
type: recovery
status: draft
version: 1.0.0
parent: "[[recovery-standard]]"
tags:
  - recovery
  - automation
---

# Automation Recovery

## Purpose

Restore the `wl-*` command layer after local corruption, accidental deletion, or failed upgrade.

## Recovery Procedure

1. Restore the automation files from Git or package.
2. Reinstall commands.
3. Run verification.
4. Review logs.

## Commands

```shell
cd ~/Wonderland/repos/wonderland-automation/04-automation/wl
./install.sh
wl-verify
```

## Rollback

```shell
rm -f ~/Wonderland/tools/bin/wl-*
```

Reinstall the previous known-good version from Git.
