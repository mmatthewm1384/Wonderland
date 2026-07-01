# Wonderland Secrets Manager

## Overview

Wonderland Secrets Manager v1 starts as a local-first skeleton for managing secret metadata safely.

This phase intentionally does not store plaintext secrets.

## Files

```text
bin/wl-secrets
vault/security/secrets-policy.json
vault/security/secrets/index.json
vault/security/secrets/store.json
docs/security/secrets.md
Commands
wl secrets verify
wl secrets list
wl secrets report
Current Guarantees
No plaintext secret storage.
Audit events are emitted for read/report operations.
Secret metadata is separated from future encrypted secret storage.
Future Improvements
Add encrypted local store.
Add Touch ID gated write operations.
Add secret rotation workflow.
Add scoped service permissions.
