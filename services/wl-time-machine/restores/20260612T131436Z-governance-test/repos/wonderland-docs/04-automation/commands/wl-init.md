---
title: wl-init
type: command
status: draft
version: 1.0.0
parent: "[[wl-command-interface]]"
tags:
  - command
  - wl
---

# wl-init

## Purpose

Initialize the local Wonderland workspace.

## Usage

```shell
wl-init
```

## Creates

```text
~/Wonderland/
├── vault/
├── repos/
├── data/
├── backups/
├── exports/
├── logs/
├── secrets/
├── tmp/
└── tools/
```

## Verification

```shell
wl-status
```

## Recovery

Re-run `wl-init` after verifying it will not overwrite existing data.

## Rollback

Rename the initialized directory:

```shell
mv ~/Wonderland ~/Wonderland.rollback.$(date +%Y%m%d-%H%M%S)
```
