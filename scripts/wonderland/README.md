# Wonderland zone discovery

Read-only, deterministic candidate discovery for Mattie's Room.

Run from the repository root:

```sh
python3 scripts/wonderland/zone_discover.py
python3 -m unittest tests.unit.test_zone_discovery -v
```

Optional arguments: `--root PATH` and `--candidate-dir PATH`.

Only direct `*.json` files in the configured candidate directory are inspected. No recursive filesystem scan, network scan, location sensing, enrollment, authorization, or writes occur. Candidate manifests use `kind: "Environment"`, with optional `metadata.id`, `metadata.name`, and `spec.environmentKind`.

Exit codes: 0 for successful discovery, 1 when candidate errors were found, 2 for invalid invocation or directory configuration.
