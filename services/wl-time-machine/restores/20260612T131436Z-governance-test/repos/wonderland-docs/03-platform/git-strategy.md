---
title: Git Strategy
type: platform
status: draft
version: 1.0.0
parent: "[[repository-strategy]]"
tags:
  - platform
  - git
---

# Git Strategy

> [!abstract]
> Defines baseline Git conventions for Wonderland-v4 repositories.

## Branch Model

Default branch:

```text
main
```

Optional working branches:

```text
feature/<name>
fix/<name>
docs/<name>
recovery/<name>
```

## Commit Standard

Commits should be clear and auditable.

Recommended format:

```text
<scope>: <change>
```

Examples:

```text
docs: add governance framework
platform: define workspace layout
ops: add backup verification procedure
```

## Tags

Stable milestones may be tagged.

Recommended format:

```text
vYYYY.MM.DD
```

## Required Repository Files

```text
README.md
.gitignore
docs/
```

## Verification

```shell
git status
git log --oneline -5
git remote -v
```

## Recovery

Clone from the authoritative remote.

## Rollback

Use Git revert for committed changes.

Use branch reset only with explicit Operator approval.
