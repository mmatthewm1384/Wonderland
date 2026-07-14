# Wonderland Runtime Phase 2 API

## Overview

Runtime Phase 2 defines one canonical terminal application architecture:

```text
RuntimeKernel
    ↓
Scene
    ↓
Frame
    ↓
Renderer
    ↓
Screen
```

The runtime is the shared terminal UI foundation for interactive Wonderland applications.

## Canonical API

Runtime drawing uses `row` and `col` coordinates.

Supported draw commands:

```python
Text
Box
Rule
```

A scene returns a `Frame`:

```python
Frame.from_commands(
    Text("Wonderland", row=1, col=2),
    Box(row=3, col=2, width=40, height=8),
    Rule(row=12, col=2),
)
```

## Responsibility Boundaries

### RuntimeKernel

Owns:

- lifecycle
- mount/update/render/unmount sequence
- render loop
- frame timing
- screen enter/exit

### Scene

Owns:

- application state
- update decisions
- returning a Frame

A Scene must not:

- sleep
- flush output
- emit ANSI
- manage terminal state

### Frame

Owns:

- immutable draw commands

### Renderer

Owns:

- converting Frame commands to screen draw calls
- alignment resolution
- terminal-size-aware composition

### Screen

Owns:

- terminal IO
- ANSI escape sequences
- cursor visibility
- alternate screen
- clear/draw/flush

## Compatibility

`Position` remains as an import-compatible value object, but new code should use `row` and `col` directly.

`launch_rootless()` remains as a legacy adapter and delegates to the RuntimeKernel path.

## Verification

Run:

```bash
python3 -m wl.runtime.phase2_certify
```

or:

```bash
bin/wl-runtime-certify
```

Expected result:

```text
PASS runtime phase2 certification
```
