---
title: Command Standard
type: standard
status: canonical
version: 1.0.0
parent: "[[wl-command-interface]]"
tags:
  - automation
  - commands
  - standard
---

# Command Standard

## Naming

Commands shall follow:

```text
wl-<action>
```

## Required Options

Every command should support:

```text
--help
--version
```

## Exit Codes

```text
0   success
1   general failure
2   invalid usage
3   missing dependency
4   verification failed
5   unsafe operation blocked
```

## Output

Commands should print:

- Action being performed
- Result
- Next recommended step on failure

## Logging

Commands may write logs to:

```text
~/Wonderland/logs/
```

## Safety

Destructive commands must require explicit confirmation unless run with documented non-interactive flags.

## Recovery

Commands must not be the only recovery mechanism.

Manual procedures must exist.
