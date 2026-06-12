# Wonderland-v3 to Wonderland-v4 Migration Model

## Source

Recovered Wonderland-v3 runtime artifacts:

- `02-overview/recovered/services/services.json`
- `02-overview/recovered/runtime/registry.json`
- `02-overview/recovered/runtime/runtime.schema.json`
- `02-overview/recovered/runtime/runtime.snapshot.json`

## Generated Architecture Graph

- `02-overview/recovered/graph/nodes.csv`
- `02-overview/recovered/graph/edges.csv`
- `02-overview/recovered/graph/wonderland-v3-runtime-summary.md`

## Migration Policy

Promote intentionally.

Do not bulk-import legacy runtime state.

## Classification

### Promote

- Service definitions
- Runtime schema
- Command registry
- Compose target references
- Documentation
- Non-secret configuration templates

### Quarantine

- Live secrets
- Private keys
- Certificates
- Harbor database files
- Poisoned or legacy Harbor state
- Runtime data directories
- Binary installers

### Archive Only

- Historical backups
- Large media
- Raw database files
- Full old snapshots
- Duplicate backup trees

## Target v4 Domains

### `03-infrastructure`

Infrastructure definitions, compose templates, service deployment material.

### `04-governance`

Policies, naming standards, recovery requirements, promotion rules.

### `05-vault`

Secrets policy, credential rotation plans, access-control documentation.

### `06-relay`

Relay, Matrix, Synapse, Element configuration templates.

### `07-timetravel`

Recovery points, snapshot index, restore procedures.

### `08-operations`

Runtime inventory, service maps, operational playbooks.

## Rule

Wonderland-v4 may reuse Wonderland-v3 knowledge.

Wonderland-v4 must not inherit Wonderland-v3 runtime fragility.
