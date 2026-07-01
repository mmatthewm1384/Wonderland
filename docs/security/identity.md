# Wonderland Identity Manager

## Overview

Wonderland Identity Manager v1 defines local advisory identity roles for platform operations.

This phase is report-only. It does not enforce access control yet.

## Files

```text
bin/wl-identity
vault/security/identity-policy.json
vault/security/identity/operators.json
docs/security/identity.md
Commands
wl identity verify
wl identity report
Roles
local-operator
automation
recovery
Design Decision

Identity is introduced before enforcement so commands can emit consistent audit events and security reports before destructive-action gating is enabled.
