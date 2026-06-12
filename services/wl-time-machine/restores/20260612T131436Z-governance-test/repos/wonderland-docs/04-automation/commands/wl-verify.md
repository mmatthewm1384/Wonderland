---
title: wl-verify
type: command
status: draft
version: 1.0.0
parent: "[[wl-command-interface]]"
tags:
  - command
  - wl
---

# wl-verify

## Purpose

Run baseline verification checks for Wonderland.

## Usage

```shell
wl-verify
```

## Checks

- Workspace layout
- Git availability
- Obsidian vault presence
- Runtime availability
- Registry presence
- Required governance documents

## Output

Human-readable verification result.

## Recovery

Failed checks should reference relevant recovery documents.
