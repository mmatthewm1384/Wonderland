# wlcli.core

Internal implementation namespace for Runtime Engine 1.0 Beta.

Rules:

- New implementation code goes under `wlcli.core`.
- Top-level modules remain compatibility shims.
- Do not create new top-level module/package name collisions.
- Python orchestrates.
- Bash executes platform-specific operations.
- Verify changes with `wl runtime verify-python`.
