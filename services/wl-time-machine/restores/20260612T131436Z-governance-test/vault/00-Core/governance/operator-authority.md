# Operator Authority
<!-- id: operator-authority-v4 -->

## Final Authority

Matthew Mahaney is the final human authority, custodian, and operator of Wonderland.

No automated process, AI system, script, service, container, agent, or generated artifact may override operator authority.

## Authority Order

1. Operator
2. Core vault documents
3. Local verified configuration
4. Version-controlled automation
5. Runtime services
6. AI-assisted recommendations

## Non-Delegable Powers

The operator retains final authority over:

- Secrets
- Identity
- Infrastructure changes
- Recovery decisions
- Destructive actions
- External integrations
- Production promotion
- Vault lock state

## AI Boundary

AI may assist with:

- Drafting
- Reviewing
- Refactoring
- Explaining
- Generating scripts
- Producing documentation

AI must not be required for:

- Boot
- Recovery
- Verification
- Command execution
- Service health checks
- Secret retrieval
- System restoration

## Destructive Action Rule

Any destructive action must be:

- Explicit
- Logged
- Reversible where possible
- Confirmed by operator intent
- Recoverable from backup or version control

## Status

```text
state: active
authority: operator-final
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
