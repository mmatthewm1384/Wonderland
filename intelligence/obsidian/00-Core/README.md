# Wonderland-v4 Seed Vault

Canonical greenfield seed vault for Wonderland-v4.

This vault establishes the initial governance, architecture, registry, platform, runtime, service, recovery, security, operations, and automation foundation.

## Foundational Doctrine

> Architect may build Wonderland.  
> Wonderland must not depend upon Architect to run.

## Directory Map

```text
00-governance/
01-architecture/
02-registry/
03-platform/
04-automation/
05-operations/
06-recovery/
07-security/
```

## Install

Copy or merge these directories into the root of the Wonderland-v4 Obsidian vault.

Recommended local workspace:

```text
~/Wonderland/
├── vault/
├── repos/
├── data/
├── backups/
├── exports/
├── logs/
├── secrets/
├── tmp/
└── tools/
```

## Bootstrap

After merging into the vault, install the initial `wl-*` command scaffold:

```shell
cd ~/Wonderland/vault/04-automation/wl
./install.sh
export PATH="$HOME/Wonderland/tools/bin:$PATH"
wl-init
wl-status
wl-verify
```

## Verification

In Obsidian, verify that these documents exist and backlink correctly:

- [[architect-charter]]
- [[wonderland-constitution]]
- [[governance-framework]]
- [[wonderland-reference-architecture]]
- [[platform-foundation]]
- [[container-runtime-policy]]
- [[service-definition-standard]]
- [[automation-foundation]]

From shell:

```shell
find ~/Wonderland/vault -maxdepth 2 -type f | sort
wl-status
wl-verify
```

## Recovery

If the vault merge fails:

1. Preserve the current vault state.
2. Restore from the previous vault backup or Git state.
3. Reapply this seed package.
4. Verify backlinks and `wl-*` commands.

Safe rollback example:

```shell
mv ~/Wonderland/vault ~/Wonderland/vault.rollback.$(date +%Y%m%d-%H%M%S)
mkdir -p ~/Wonderland/vault
```

Do not delete rollback copies until verified.

## Contents

This seed includes:

- Architect Charter
- Wonderland Constitution
- Governance Framework
- Naming, documentation, recovery, security, and change standards
- Reference architecture
- Domain model
- System context
- Trust boundaries
- Dependency policy
- Registries
- Platform foundation
- Runtime foundation
- Service foundation
- Automation foundation
- ADRs 0000-0017
