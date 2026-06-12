# Wonderland-v4 Canonical Docs Repository

This repository is the canonical greenfield documentation, governance, architecture, registry, operations, recovery, security, and automation knowledge core for Wonderland-v4.

## Foundational Doctrine

> Architect may build Wonderland.  
> Wonderland must not depend upon Architect to run.

## Canonical Placement

This repository shall be installed at:

```text
~/Wonderland/repos/wonderland-docs
```

This directory is both:

```text
Git repository
Obsidian vault
```

There is no separate canonical `~/Wonderland/vault`.

## Correct Workspace Layout

```text
~/Wonderland/
├── repos/
│   ├── wonderland-docs/
│   ├── wonderland-platform/
│   ├── wonderland-automation/
│   ├── wonderland-services/
│   └── wonderland-ops/
├── data/
├── backups/
├── exports/
├── logs/
├── secrets/
├── tmp/
└── tools/
```

## Install

```shell
mkdir -p ~/Wonderland/repos
cd ~/Wonderland/repos
unzip ~/Downloads/wonderland-docs-v4-canonical.zip -d wonderland-docs
cd wonderland-docs
git status
```

Open this folder in Obsidian:

```text
~/Wonderland/repos/wonderland-docs
```

## Bootstrap `wl-*`

```shell
cd ~/Wonderland/repos/wonderland-docs/04-automation/wl
./install.sh
export PATH="$HOME/Wonderland/tools/bin:$PATH"
wl-init
wl-status
wl-verify
```

Persist PATH:

```shell
echo 'export PATH="$HOME/Wonderland/tools/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## Verification

```shell
cd ~/Wonderland/repos/wonderland-docs
git status
git log --oneline -1
wl-status
wl-verify
```

## Recovery

Recover the knowledge core by restoring or cloning:

```text
~/Wonderland/repos/wonderland-docs
```

Do not restore to a separate `~/Wonderland/vault` directory.

## Contents

- Architect Charter
- Wonderland Constitution
- Governance Framework
- Standards
- Reference Architecture
- Registries
- Platform Foundation
- Runtime Foundation
- Service Foundation
- Automation Foundation
- ADRs 0000-0017
