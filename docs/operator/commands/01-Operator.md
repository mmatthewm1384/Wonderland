# Wonderland Operator

## Purpose

The Operator is the operational control plane for Wonderland.

Responsibilities:

- Dashboard
- Workspaces
- Health
- Events
- Notifications
- tmux frontend
- Future TUI / GUI

---

## Lifecycle

python3 -m wl.operator start

python3 -m wl.operator stop

python3 -m wl.operator restart

python3 -m wl.operator attach

python3 -m wl.operator reload

---

## Status

python3 -m wl.operator status

python3 -m wl.operator status --json

---

## Diagnostics

python3 -m wl.operator verify

python3 -m wl.operator doctor

---

## State

state/operator/

operator.json

status.json

events.jsonl

notifications.jsonl

operator.tmux.conf

---

## Workspaces

development

builder

incident

full

---

## Keyboard

Ctrl-a r Runtime

Ctrl-a b Builder

Ctrl-a c Chaos

Ctrl-a s Security

Ctrl-a g Git

Ctrl-a L Logs

Ctrl-a x Scratch
