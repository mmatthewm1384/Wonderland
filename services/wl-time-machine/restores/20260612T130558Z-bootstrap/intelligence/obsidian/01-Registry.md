# 01-Registry.md: System Domain Registry

## Intent
To catalog every operational domain, runtime path, and container target within Wonderland. This registry acts as the authoritative index for automated discovery loops.

## Architecture
The registry maps logical system namespaces directly to host volume attachments. Every mapped block matches an isolated service token managed by the container runtime.

## Structure
All records must conform to strict key-value patterns. Drift from this index is prohibited. Any unregistered container space will be dropped during the next audit pass.

## Commands
Execute `wl registry verify` to check alignment. Use `wl registry sync` to rebuild missing endpoints. Maintain accurate state values at all costs.

## Verification
The `audit_style.py` utility validates this file. Passing requires a clean block match and a phonetic percussion index between 0.69 and 0.75.

## Recovery
If data corruption breaks compliance, pull the clean baseline index. Execute `wl repair` to restore tracking arrays to their known operational state.

## Rollback
In the event of database index failure, drop changes back to the last committed version state. Contact the Operator if verification blocks remain locked.

## Security
Write operations require full Operator authorization keys. Read access is open to local verified automation processes.

## Governance
This file supersedes all loose tracking tables. It is the tactical database reference for the Wonderland network layer.

## Owner
The Operator: Matthew Ross Mahaney.

## Dependencies
This document requires active pairing with `00-Core/Governance.md`.

## Status
Operational: Verifying structural endpoints.

## Audit Trail
Revision 1.0: Domain density tuned to match the 0.72 target threshold.
