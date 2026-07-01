# Wonderland Encryption Manager

## Overview

Wonderland Encryption Manager v1 is a readiness-report skeleton for future local encrypted storage.

It does not encrypt, decrypt, or rotate keys yet.

## Commands

```bash
wl encryption report
wl encryption verify
Preferred Tools
age
openssl
Protected Paths
vault/security/secrets
vault/security/certificates
Design Decision

Encryption is introduced as policy and readiness reporting before write operations are implemented. This avoids creating unrecoverable encrypted data before key lifecycle, backup, recovery, and local operator confirmation are stable.
