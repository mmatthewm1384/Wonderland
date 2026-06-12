# WIL Runtime

WIL is the Wonderland Intent Language.

Current runtime:

- Primary: Rust engine at `tools/wil-rust`
- Fallback: Python bootstrap at `tools/wil/src/wil.py`
- Wrapper: `bin/wl-wil`

## Core commands

```bash
bin/wl-wil doctor
bin/wl-wil status
bin/wl-wil compile <file>
bin/wl-wil plan <program.json>
bin/wl-wil run <program.json> --yes key=value
bin/wl-wil inspect <program.json> key=value
bin/wl-wil rollback <program.json> --yes key=value
bin/wl-wil recover <program.json> --yes key=value
bin/wl-wil timeline
bin/wl-wil graph
bin/wl-wil graph-json
bin/wl-wil world <id>
Model

A WIL program performs governed change:
intent
requires
do
prove
outputs
recover
rollback
event
audit
Recovery

Disable Rust runtime:mv tools/wil-rust/target/release/wil.disabled tools/wil-rust/target/release/wil
