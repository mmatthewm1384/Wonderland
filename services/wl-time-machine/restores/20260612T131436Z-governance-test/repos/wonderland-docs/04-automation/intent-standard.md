---
title: Intent Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[automation-standard]]"
tags:
  - automation
  - intents
  - json
---

# Intent Standard

> [!abstract]
> Defines `.intent.json` files for describing requested automation outcomes.

## Purpose

Intent files provide auditable, versionable, machine-readable descriptions of requested operations.

## Naming

Intent files shall follow:

```text
<action>.intent.json
```

## Required Fields

```json
{
  "intent_version": "1.0.0",
  "name": "example",
  "mode": "DESIGN",
  "summary": "Human-readable summary.",
  "requested_by": "Operator",
  "created": "YYYY-MM-DD",
  "target": {},
  "constraints": [],
  "verification": [],
  "rollback": []
}
```

## Modes

```text
DESIGN
BUILD
REVIEW
RECOVERY
HANDOFF
```

## Secret Handling

Intent files must not contain secret values.

## Verification

Intent files should be validated before execution.

## Recovery

Intent files should remain available as historical evidence of requested change.
