# Wonderland Security

## Overview

Wonderland Security is the shared local-first security foundation for the platform.

Current modules:

- Audit Log
- Permissions Policy
- Secrets Manager skeleton
- Identity Manager skeleton
- Security Report
- Security Dashboard

## Commands

```bash
wl security report
wl security dashboard
wl security certify
wl audit verify
wl permissions verify
wl secrets verify
wl identity verify
Files
bin/wl-security
bin/wl-security-report
bin/wl-security-dashboard
bin/wl-security-certify
vault/security/
logs/security/
docs/security/
Current Mode

Security is currently advisory and report-oriented.

Blocking enforcement should wait until:

mirror recovery is certified
audit logging is stable
secrets storage is encrypted
local operator confirmation is implemented
destructive-action rollback is tested
