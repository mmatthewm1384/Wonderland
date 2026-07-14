# Wonderland Runtime UI Framework

The Runtime UI Framework provides reusable terminal UI primitives for Wonderland OS commands.

## Current Consumers

- `wl start`
- `wl runtime doctor`
- `wl runtime verify`
- `wl runtime status`
- `wl runtime theme`

## Components

| Module | Purpose |
|---|---|
| `renderer.py` | Alternate-screen terminal rendering |
| `layout.py` | Centering and terminal sizing |
| `colors.py` | ANSI color tokens |
| `progress.py` | Progress bar rendering |
| `animation.py` | Dual-spinner animation frames |
| `components.py` | Header, footer, and status list primitives |
| `themes/` | Runtime UI theme registry |
| `checks.py` | Runtime health checks |
| `status.py` | Runtime status persistence |

## Design Intent

The framework should become the shared terminal interface for Wonderland platform commands:

- startup
- doctor
- verify
- install
- recovery
- builder
- services
- scheduler

## Principles

- terminal-first
- low dependency
- local-first
- deterministic output where needed
- graceful non-animation mode
- machine-readable status files
- reusable UI primitives
