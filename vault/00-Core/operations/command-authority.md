# Command Authority
<!-- id: command-authority-v4 -->

## Naming Standard

All Wonderland commands begin with:

```text
wl

or

wl-*
Command Categories

Core

wl
wl doctor
wl status
wl verify

Services

wl dns
wl vault
wl universe
wl launcher
wl chronosphere

Operations

wl backup
wl restore
wl promote
wl review
wl recover
Command Requirements

Every command should support:

help
status
verify

Example

wl dns help
wl dns status
wl dns verify
Failure Rule

Commands must:

fail loudly
return exit codes
log errors
avoid silent state corruption
Recovery Rule

Every command capable of modification must have:

verification
rollback
recovery documentation
Status

state: active
version: 4
