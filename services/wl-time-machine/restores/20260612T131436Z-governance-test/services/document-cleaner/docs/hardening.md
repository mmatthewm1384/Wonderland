# Document Cleaner Hardening

Status:
Functional, hardening pending.

Current compromise:
read_only is disabled because rootless nerdctl made /tmp read-only under the initial read_only configuration.

Future hardening:

- Restore read_only filesystem
- Provide explicit writable tmpfs for /tmp and /var/tmp
- Set TMPDIR, TMP, and TEMP
- Verify Werkzeug upload temp behavior
- Retest PDF and image sanitization
- Preserve fail-closed behavior

state: active
version: 4
