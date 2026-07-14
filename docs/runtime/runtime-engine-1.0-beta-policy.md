# Runtime Engine 1.0 Beta Policy

## Purpose

Runtime Engine 1.0 Beta marks the transition from patch-driven CLI growth to module-driven runtime architecture.

## Rule

Stop modifying core runtime files with fragile string-replacement patch scripts except for emergency repair.

Prefer:

- new modules
- explicit imports
- small reviewed refactors
- stable interfaces
- compile verification before runtime tests

## Package Direction

Runtime code should move toward:

```text
wlcli/
  commands/
  graph/
  report/
  runtime/
  state/
  ui/
Output Contract

Commands should return structured result objects.

Renderers should be the only components that know about:

terminal colors
formatting
JSON output
future TUI/Control Center presentation
Bash/Python Boundary

Python owns:

orchestration
state
graph execution
validation
history
metrics
reports
rendering

Bash owns:

platform-specific execution
macOS integration
Lima/nerdctl operations
app lifecycle shims

The stable boundary is an operation interface, not ad hoc subprocess calls scattered across command handlers.

Required Verification

After runtime Python changes:

wl runtime verify-python
wl self-test
wl graph doctor
Migration Policy

Existing working commands remain compatible.

New Runtime Engine 1.0 Beta work should be added as modules first, then wired through the command registry deliberately.
