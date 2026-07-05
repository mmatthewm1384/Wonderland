# Wonderland Operator

## Overview

Wonderland Operator is the local-first operational subsystem for Wonderland OS.

It provides a unified command center for:

- Runtime
- Builder
- Chaos
- Security
- Logs
- Git
- Future storage, vault, scheduler, AI, and Control Center integrations

## Architecture

Operator is designed as a subsystem, not a tmux script.

```text
wl operator
    ├── core model
    ├── capability registry
    ├── health aggregation
    ├── dashboard renderer
    ├── tmux backend
    └── future TUI / GUI frontends
tmux is the first backend. It is not the long-term API boundary.

Commands
wl operator start
wl operator stop
wl operator restart
wl operator attach
wl operator status
wl operator reload
wl operator verify
Design Decisions
Local-first
No external service dependency
Declarative subsystem manifest
Shared health model
Capability registry
Backend/frontend separation
Future Control Center compatibility
State
state/operator/
├── operator.json
└── operator.tmux.conf
Future Improvements
Event bus
Plugin discovery
JSON status contracts
Native TUI
Native GUI Control Center
