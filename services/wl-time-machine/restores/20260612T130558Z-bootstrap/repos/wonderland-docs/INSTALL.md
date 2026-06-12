# Install `wonderland-docs`

## Canonical Target

```text
~/Wonderland/repos/wonderland-docs
```

This directory is both the Git repository and the Obsidian vault.

## Fresh Install

```shell
mkdir -p ~/Wonderland/repos
cd ~/Wonderland/repos
unzip ~/Downloads/wonderland-docs-v4-canonical.zip -d wonderland-docs
cd wonderland-docs
```

## Verify Repository

```shell
git status
git log --oneline -1
```

## Open Obsidian

Open this folder as the vault:

```text
~/Wonderland/repos/wonderland-docs
```

## Install `wl-*`

```shell
cd ~/Wonderland/repos/wonderland-docs/04-automation/wl
./install.sh
export PATH="$HOME/Wonderland/tools/bin:$PATH"
wl-init
wl-status
wl-verify
```

## Recovery

If installed incorrectly to `~/Wonderland/vault`, move it into the canonical location:

```shell
mkdir -p ~/Wonderland/repos
mv ~/Wonderland/vault ~/Wonderland/repos/wonderland-docs
```

Then verify:

```shell
cd ~/Wonderland/repos/wonderland-docs
git status
```

## Rollback

If migration fails:

```shell
mv ~/Wonderland/repos/wonderland-docs ~/Wonderland/repos/wonderland-docs.failed.$(date +%Y%m%d-%H%M%S)
```
