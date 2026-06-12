---
title: Bootstrap Plan
type: operations
status: canonical
version: 1.1.0
parent: "[[platform-foundation]]"
tags:
  - operations
  - bootstrap
---

# Bootstrap Plan

> [!abstract]
> Defines the initial procedure for establishing a local Wonderland-v4 workspace.

## Canonical Model

`wonderland-docs` is both the Git repository and Obsidian vault.

Canonical path:

```text
~/Wonderland/repos/wonderland-docs
```

## Prerequisites

- macOS or Linux
- Git
- Shell environment
- Obsidian
- `wonderland-docs-v4-canonical.zip` or Git remote

## Procedure

```shell
mkdir -p ~/Wonderland/{repos,data,backups,exports,logs,secrets,tmp,tools}
cd ~/Wonderland/repos
unzip ~/Downloads/wonderland-docs-v4-canonical.zip -d wonderland-docs
cd wonderland-docs
```

## Install Automation

```shell
cd ~/Wonderland/repos/wonderland-docs/04-automation/wl
./install.sh
export PATH="$HOME/Wonderland/tools/bin:$PATH"
wl-init
wl-status
wl-verify
```

## Verification

```shell
test -d ~/Wonderland/repos/wonderland-docs
cd ~/Wonderland/repos/wonderland-docs
git status
wl-status
wl-verify
```

## Recovery

Restore:

1. `~/Wonderland/repos/wonderland-docs` from Git or backup.
2. Other repositories from remotes.
3. Data from backups.
4. Secrets from approved secret recovery process.

## Rollback

If created incorrectly:

```shell
mv ~/Wonderland ~/Wonderland.rollback.$(date +%Y%m%d-%H%M%S)
```

Do not delete until contents are verified.
