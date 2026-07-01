# Wonderland Integrity Inspector

## Overview

Wonderland Integrity Inspector v1 verifies that required security files exist and records SHA-256 hashes for core security policy files.

This phase is report-only.

## Files

```text
bin/wl-integrity
vault/security/integrity/manifest.json
logs/security/integrity-report.json
docs/security/integrity.md
Commands
wl integrity verify
wl integrity report
Design Decision

The first integrity implementation does not block execution. It creates a stable baseline for later enforcement, attestation, and recovery workflows.
