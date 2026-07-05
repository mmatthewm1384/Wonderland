# Wonderland Architecture Standard v1.0

## Status

```text
STANDARD: ACTIVE
Purpose

The Wonderland Architecture Standard defines the canonical engineering model for all major Wonderland subsystems.

Operator v1.0-alpha is the reference implementation.

Core Principle

Every major subsystem should be:

reliable
local-first
secure by default
observable
recoverable
declarative where practical
documented
verifiable
maintainable
Standard Subsystem Layout
wl/<subsystem>/
├── __init__.py
├── __main__.py
├── kernel.py
├── manifest.json
├── state.py
├── status.py
├── health.py
├── verify.py
├── doctor.py
├── events.py
├── notifications.py
├── backend/
├── plugins/
├── api/
└── README.md

Not every subsystem requires every file, but deviations should be intentional and documented.

Required Commands

Each major subsystem should expose:

wl <subsystem> status
wl <subsystem> status --json
wl <subsystem> verify
wl <subsystem> doctor

Lifecycle-capable subsystems should also expose:

wl <subsystem> start
wl <subsystem> stop
wl <subsystem> restart
State Layout

Subsystem state belongs under:

state/<subsystem>/
├── manifest.json
├── status.json
├── events.jsonl
├── notifications.jsonl
└── cache/
Manifest Contract

Each subsystem manifest should include:

{
  "name": "operator",
  "title": "Wonderland Operator",
  "version": "1.0-alpha",
  "status": "alpha",
  "intent": "Unified local-first operator environment",
  "capabilities": [],
  "state_dir": "state/operator"
}
Status Contract

Each subsystem should emit stable JSON:

{
  "name": "operator",
  "version": "1.0",
  "state": "healthy",
  "summary": "operational",
  "capabilities": [],
  "health": {},
  "events": {},
  "notifications": {}
}
Health States

Allowed health states:

healthy
busy
warning
failed
offline
unknown
Event Contract

Events are append-only JSON Lines records:

{
  "timestamp": "2026-07-05T00:00:00Z",
  "source": "operator",
  "type": "started",
  "payload": {}
}
Notification Contract

Notifications are append-only JSON Lines records:

{
  "timestamp": "2026-07-05T00:00:00Z",
  "source": "operator",
  "level": "info",
  "title": "Operator started",
  "message": "Workspace active",
  "payload": {}
}

Allowed levels:

info
success
warning
error
critical
Kernel Responsibility

The kernel owns subsystem lifecycle and orchestration.

It should not own presentation logic.

Backend Separation

Backends implement execution details.

Examples:

tmux
systemd
launchd
container
filesystem
native-ui
Plugin Model

Plugins extend subsystem capabilities without modifying the kernel.

Plugins should expose stable contracts and avoid side effects during import.

Verification

verify checks structure and static correctness.

Examples:

required files exist
manifests parse
status contract is valid
plugin registry loads
Python modules compile
Doctor

doctor checks operational health.

Examples:

dependencies installed
runtime state exists
backends reachable
permissions valid
recovery paths available
Documentation Requirements

Each subsystem should document:

Overview
Architecture
Commands
State
Configuration
Security
Recovery
Troubleshooting
Roadmap
Design Decisions
Maturity Levels
Level	Meaning
Prototype	Exploratory, unstable
Alpha	Core architecture exists
Beta	API stabilizing
Stable	Production-ready
LTS	Long-term compatibility commitment
Reference Implementation
wl/operator/

Wonderland Operator v1.0-alpha is the reference implementation for this standard.
