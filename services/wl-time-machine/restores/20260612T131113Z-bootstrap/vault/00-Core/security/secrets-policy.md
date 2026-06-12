# Secrets Policy
<!-- id: secrets-policy-v4 -->

## Rule

Secrets must not be stored in plaintext core documents, Git history, logs, screenshots, or generated examples.

## Secret Types

Secrets include:

- API keys
- Tokens
- Private keys
- Passwords
- Recovery phrases
- Signing keys
- Session cookies

## Storage Rule

Secrets must be stored in approved secure storage only.

Core documents may reference secret names, never secret values.

## Rotation Rule

Any exposed secret must be considered compromised and rotated.

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
