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
