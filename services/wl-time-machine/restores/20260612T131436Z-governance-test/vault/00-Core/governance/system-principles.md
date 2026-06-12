# Wonderland System Principles
<!-- id: system-principles-v4 -->

## Prime Directive

Wonderland may be built with AI assistance.

Wonderland must not depend on AI to run.

## Design Principles

Wonderland systems must be:

- Persistent
- Recoverable
- Auditable
- Secure
- Automated
- Versioned
- Modular

## Operational Principles

Every service, command, and document should support:

- Local inspection
- Local verification
- Deterministic rebuild
- Explicit ownership
- Clear rollback
- Minimal hidden state

## Naming Standards

Commands:

```text
wl-*
Services:

wl-<service>

Containers:

wl-<service>

Networks:

wonderland-*

Volumes:

wl-<service>-data

Documents:

lowercase-kebab-case.md

Intent files:

*.intent.json
Structural Rule

If a system cannot be explained, verified, recovered, and removed, it is not ready for core promotion.

Status
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
