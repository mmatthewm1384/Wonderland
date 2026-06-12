---
title: Repository Record
type: repository
status: canonical
version: 1.0.0
tags:
  - repository
  - wonderland-docs
---

# Repository Record

## Name

`wonderland-docs`

## Purpose

Canonical Git-backed Obsidian documentation repository for Wonderland-v4.

## Contains

- Governance
- Architecture
- Standards
- ADRs
- Registries
- Operations docs
- Recovery docs
- Security docs
- Automation docs

## Authority

This repository is the initial source of truth for the Wonderland-v4 knowledge core.

## Verification

```shell
git status
git log --oneline -5
find . -maxdepth 2 -type f | sort
```

## Recovery

Clone the authoritative remote or restore from a verified backup.

## Rollback

Use Git revert for committed changes.

Avoid destructive history rewrites unless explicitly approved by the Operator.
