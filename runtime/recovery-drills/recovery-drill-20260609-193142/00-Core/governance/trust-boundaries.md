# Trust Boundaries
<!-- id: trust-boundaries-v4 -->

## Authority Boundary

Wonderland authority flows in this order:

1. Operator
2. Core Vault
3. Version-Controlled Configuration
4. Local Automation
5. Runtime Services
6. External Systems
7. AI Assistance

## Operator Boundary

The operator is the final authority for:

- Identity
- Secrets
- Destructive actions
- Promotion into core
- Recovery decisions
- External integrations

## AI Boundary

AI may assist with design, review, documentation, and implementation drafts.

AI must not be required for boot, verification, recovery, secret access, or production operation.

## Runtime Boundary

Runtime state is not authority.

Runtime may report facts, but core documents define intended structure.

## External Boundary

External systems may provide services but must not become single points of unrecoverable authority.

## Status

state: active
version: 4
