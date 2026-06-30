# Chaos Session + Intent Handoff

Status: PASS

## Completed

- Reorganized menubar into:
  - Authority
  - Session
  - Models
  - Intent
  - Scheduler
  - Tools
  - Advanced
- Added Session section:
  - Model
  - Intent
  - State
- Removed duplicate Chaos Intents menu.
- Added intent registry.
- Added active intent state.
- Added wl-chaos-intent.
- Added wl-chaos-current-intent.
- Added controller-driven environment engine.
- Added Matrix and Menubar controllers.
- Added model profiles under vault/chaos/models.
- Added profile-to-registry synchronization.
- Preserved Touch ID gating for elevated models.
- Preserved model lease synchronization.
- Verified model and intent state update through backend.

## Known follow-ups

- Complete Matrix app native key registry:
  - F fullscreen
  - H controls
  - P Wonderland mode
  - 1-7 modes
- Replace symlinked app source with tracked source or proper worktree/submodule.
- Implement wl checkpoint create.
- Add Session Since timestamp.
- Add controller dashboard/status section.

