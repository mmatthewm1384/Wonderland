# Disaster Recovery
<!-- id: disaster-recovery-v4 -->

## Objective

Restore Wonderland after:

- Operator workstation failure
- SSD failure
- Filesystem corruption
- Accidental deletion
- Repository corruption
- Service failure

## Recovery Sources

Priority Order:

1. Vault
2. Git
3. Backups
4. Archives
5. Reconstructed Runtime

## Recovery Targets

Tier 0

- Identity
- Governance
- Recovery

Tier 1

- Infrastructure
- Automation
- Services

Tier 2

- Projects
- Media
- Knowledge

## Success Criteria

A restored Wonderland can:

- Verify itself
- Start services
- Execute commands
- Recover backups

Without AI assistance.

state: active
version: 4

## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
