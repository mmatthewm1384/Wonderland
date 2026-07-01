# Wonderland Permissions Policy

## Overview

Wonderland Permissions Policy v1 defines local advisory rules for sensitive platform actions.

This is intentionally advisory first. It validates policy structure and exposes security intent without prematurely blocking recovery or development workflows.

## Files

```text
bin/wl-permissions
vault/security/permissions-policy.json
docs/security/permissions.md
Commands
wl permissions verify
wl permissions report
Modes
advisory
enforcing

The current mode is:

advisory
Resources

Current policy covers:

mirror
security
secrets
Design Decision

Enforcement should not be enabled until:

audit logging is stable
recovery paths are tested
operator confirmation exists
Touch ID or equivalent local authentication is integrated for destructive actions
