---
title: Fix Incorrect Vault Install
type: operations
status: canonical
version: 1.0.0
tags:
  - operations
  - migration
  - fix
---

# Fix Incorrect Vault Install

## Problem

Wonderland docs were installed to:

```text
~/Wonderland/vault
```

## Correct Target

```text
~/Wonderland/repos/wonderland-docs
```

## Migration

```shell
mkdir -p ~/Wonderland/repos

if [ -d ~/Wonderland/repos/wonderland-docs ]; then
  mv ~/Wonderland/repos/wonderland-docs ~/Wonderland/repos/wonderland-docs.pre-migration.$(date +%Y%m%d-%H%M%S)
fi

mv ~/Wonderland/vault ~/Wonderland/repos/wonderland-docs
cd ~/Wonderland/repos/wonderland-docs
git status
```

## Obsidian

Open:

```text
~/Wonderland/repos/wonderland-docs
```

as the vault.

## Verify

```shell
cd ~/Wonderland/repos/wonderland-docs/04-automation/wl
./install.sh
export PATH="$HOME/Wonderland/tools/bin:$PATH"
wl-status
wl-verify
```

## Rollback

If migration fails:

```shell
mv ~/Wonderland/repos/wonderland-docs ~/Wonderland/vault
```
