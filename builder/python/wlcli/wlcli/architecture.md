# Wonderland Runtime Engine 1.0 Beta Architecture

## Package Boundaries

```text
wlcli/
  commands/        Command handlers
  graph/           Boot graph model, execution, validation
  report/          Report builders
  runtime/         Runtime context and Bash operation interface
  state/           History, metrics, persisted state
  ui/              Terminal and JSON renderers
Output Contract

All commands should move toward returning:

CommandResult

A CommandResult can be rendered as:

terminal text
JSON
future TUI
Control Center data

Only renderer modules should know about terminal colors.

Bash/Python Boundary

Python owns:

orchestration
graph execution
state
history
metrics
reports
dispatch
rendering

Bash owns:

platform operations
macOS-specific behavior
Lima/nerdctl process control
app launch/stop shims
subsystem-specific commands

The stable bridge is:

PlatformOperations
BashOperationRunner
OperationResult
Migration Rule

Do not rewrite working commands during consolidation.

Add new package boundaries first.
Move behavior gradually.
Keep compatibility aliases operational.
