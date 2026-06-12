---
title: Repository Governance
type: governance
status: canonical
version: 1.0.0
parent: "[[governance-framework]]"
tags:
  - governance
  - repository
---

# Repository Governance

## Purpose

Defines governance rules for the `wonderland-docs` repository.

## Rules

- Canonical documentation must be committed to Git.
- Significant changes should reference an ADR or issue.
- Secrets must not be committed.
- Generated exports and local backups must not be committed.
- Obsidian local workspace state must not be committed.

## Commit Requirements

Commits should be clear, scoped, and auditable.

Example:

```text
docs: add platform foundation
adr: accept shell-first command layer
governance: update documentation standard
```

## Verification

```shell
git status
git diff --stat
git log --oneline -5
```

## Recovery

Recover from remote Git or verified repository backup.
