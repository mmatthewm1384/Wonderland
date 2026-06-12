# WL-GOV-004 — Authority Persistence Standard

## Status

Active

## Purpose

Wonderland must separate authoritative runtime state from persistence storage.

## Authority Root

The MacBook local root is authoritative:

```text
/Users/wonderland/Wonderland
This root contains:

commands
governance
registry
service definitions
runtime control
documentation authority
operational policy
Persistence Root

The T7 root is persistent storage:

/Volumes/T7_Wonderland

This root may contain:

media
backups
archives
snapshots
exports
large immutable datasets
historical imports
Rule

Authoritative execution must not depend on T7 being mounted.

If T7 is unavailable:

wl doctor must still run
governance must still verify
registry integrity must still verify
runtime drift must still verify
services may degrade only if their declared persistent data requires T7
Prohibited

The following must not live only on T7:

bin/
tools/
vault/09-Governance/
vault/05-Registry/
vault/06-Services/definitions/
primary wl command authority
Principle

Runtime state is disposable.
Authority is not.
