# Threat Model
<!-- id: threat-model-v4 -->

## Protected Assets

Wonderland protects:

- Operator identity
- Core vault
- Secrets
- Backups
- Runtime configuration
- Source repositories
- Infrastructure definitions

## Primary Threats

- Accidental deletion
- Credential exposure
- Configuration drift
- Unauthorized service access
- Backup failure
- Dependency compromise
- AI-generated unsafe changes

## Required Controls

- Version control
- Verification scripts
- Backups
- Secret isolation
- Least privilege
- Rollback procedures
- Operator approval for destructive changes

## Status

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
