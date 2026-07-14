# Wonderland Intent — Runtime Engine 1.0

## Intent

Evolve `wl` from a launcher into the primary operating console for Wonderland.

Runtime Engine 1.0 will provide a modular, graph-driven, observable, recoverable, and extensible control plane for the local-first Wonderland ecosystem.

## North Star

Wonderland Runtime Engine 1.0 should feel like a polished operating environment:

- reliable
- inspectable
- recoverable
- beautiful
- modular
- local-first
- automation-ready
- future GUI/TUI compatible

## Current Foundation

Runtime Engine 0.9 already includes:

- `bin/wl` as the primary entrypoint
- Python-backed `wlcli`
- Boot Graph execution
- graph validation
- graph JSON output
- persisted graph state
- graph logs
- graph current summary
- boot reports
- report JSON output
- graph doctor
- registry-backed help/dispatch
- Bash subsystem compatibility

## Runtime Engine 1.0 Scope

### 1. Modular Package Layout

Refactor `wlcli` into clear modules:

```text
wlcli/
  app.py
  runtime.py

  graph/
    model.py
    executor.py
    validator.py
    persistence.py

  registry/
    discover.py
    dispatcher.py

  report/
    builder.py
    renderer.py
    json.py

  ui/
    palette.py
    terminal.py
    progress.py

  doctor/
    graph.py
    runtime.py
    platform.py

  state/
    history.py
    metrics.py

  commands/
    start.py
    stop.py
    status.py
    graph.py
    report.py
    doctor.py
2. Runtime History

Record every lifecycle run to:

vault/08-Operations/state/runtime-history.jsonl

Each entry should include:

timestamp
command
result
total duration
stage results
logs
profile
runtime instance

Planned commands:

wl history
wl history --last 20
wl history --failures
wl history --today
3. Runtime Profiles

Support named profiles:

wl start --profile default
wl start --profile minimal
wl start --profile development
wl start --profile observability
wl start --profile desktop
wl start --profile ci

Profiles define:

enabled stages
required stages
optional stages
service policy
app policy
verification policy
4. Metrics

Persist runtime metrics to:

vault/08-Operations/state/runtime-metrics.json

Metrics should include:

average boot time
fastest boot
slowest boot
failure count
per-stage timing
last successful boot
last failed boot
5. Better Recovery

Future recovery commands:

wl recover
wl recover --last-good
wl rollback-runtime
wl graph-open-log <stage>

Recovery should prefer:

last known good graph state
checkpoint awareness
safe stop/start retry
non-destructive repair
6. TUI/GUI Readiness

Runtime Engine 1.0 must expose structured data for future interfaces:

wl graph-json
wl graph-current-json
wl boot-report-json
wl commands-json
wl history-json
wl metrics-json

Terminal UI, Control Center, and future dashboard layers should consume the same data model.

Design Constraints
Keep Bash subsystem scripts operational.
Do not rewrite stable platform controls unnecessarily.
Python orchestrates; Bash performs platform operations.
Prefer JSONL for append-only operational history.
Prefer JSON for current state and metrics.
Never hide logs.
Never report PASS if required runtime state is degraded.
Optional stages may warn, but required stages must fail loudly.
All commands must be local-first and recoverable.
Success Criteria

Runtime Engine 1.0 is complete when:

wl self-test
wl graph-doctor
wl start
wl graph-current
wl boot-report
wl history
wl metrics
wl stop

all operate through the modular Python runtime engine and produce structured, inspectable artifacts.

Final Definition

Runtime Engine 1.0 is the point where wl becomes the stable operating console for Wonderland.

It is no longer only a launcher.

It is the command surface, state model, runtime graph, diagnostic layer, and operational memory of the Wonderland ecosystem.
