---
title: wl-status
type: command
status: draft
version: 1.0.0
parent: "[[wl-command-interface]]"
tags:
  - command
  - wl
---

# wl-status

## Purpose

Report local Wonderland workspace status.

## Usage

```shell
wl-status
```

## Checks

- Workspace root
- Vault directory
- Repository directory
- Backup directory
- Log directory
- Git availability
- Container runtime availability

## Exit Codes

```text
0   workspace appears valid
4   verification failed
```

## Recovery

Run `wl-init` or follow [[bootstrap-plan]].
