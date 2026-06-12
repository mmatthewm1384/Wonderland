---
title: Audit Logging Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[automation-standard]]"
tags:
  - automation
  - audit
  - logging
---

# Audit Logging Standard

> [!abstract]
> Defines minimum audit logging expectations for Wonderland automation.

## Purpose

Audit logs preserve operational evidence.

## Log Location

Default local log directory:

```text
~/Wonderland/logs/
```

## Log Naming

```text
wl-<command>-YYYYMMDD.log
```

## Required Log Events

Automation should log:

- Command invoked
- Timestamp
- Operator or user context when available
- Working directory
- Inputs or intent file path
- Major actions
- Verification result
- Exit code

## Secret Redaction

Logs must not contain secret values.

## Failure Logs

Failures should include:

- Failed step
- Observed state
- Recovery recommendation

## Retention

Retention policy shall be defined per environment.
