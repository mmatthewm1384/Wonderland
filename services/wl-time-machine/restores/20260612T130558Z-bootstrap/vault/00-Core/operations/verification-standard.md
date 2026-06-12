# Verification Standard
<!-- id: verification-standard-v4 -->

## Rule

Every promoted Wonderland artifact must define a verification method.

## Verification Types

- File existence
- JSON validity
- Markdown identity marker
- Service health
- Port availability
- Backup integrity
- Restore test
- Command exit code

## Command Standard

Verification commands should be callable through:

```text
wl verify

or:

wl <system> verify
Result Standard

Verification must return:

Exit code 0 on success
Non-zero exit code on failure
Human-readable output
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
