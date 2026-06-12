
# WIL Rust Runtime Handoff

## Status

WIL has been migrated toward a Rust-first runtime with Python fallback.

## Active paths

- Rust source: `tools/wil-rust/src/main.rs`

- Rust manifest: `tools/wil-rust/Cargo.toml`

- Python fallback: `tools/wil/src/wil.py`

- Wrapper: `bin/wl-wil`

- Governance root: `vault/09-Governance/wil`

## Verified capabilities

- doctor

- status

- compile

- plan

- run

- inspect

- rollback

- recover

- timeline

- graph

- graph-json

- world verification

- event emission

- audit emission

## Important rule

WIL should evolve as a governed programming language, not a loose script runner.

Every executable WIL program should define:

- intent

- requires

- do

- prove

- outputs

- recover

- rollback

## Next recommended work

1. Add `drift`

2. Add `reconcile`

3. Add typed WIL schema validation

4. Add Rust tests

5. Add native WIL syntax later

## Recovery

Use Python fallback if Rust breaks.

```bash

mv tools/wil-rust/target/release/wil tools/wil-rust/target/release/wil.disabled

bin/wl-wil doctor
