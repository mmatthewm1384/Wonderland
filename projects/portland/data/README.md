# Data governance boundary

This tree is for data lifecycle organization and manifests. It is not permission
to copy or redistribute source datasets.

- `00-incoming/` — quarantine/intake; inspect license, provenance, malware risk,
  sensitivity, schema, and integrity before promotion.
- `01-source/` — approved immutable source snapshots or references.
- `02-staged/` — normalized working copies with reproducible transformations.
- `03-derived/` — derived datasets with complete lineage.
- `04-restricted/` — access-controlled material; do not commit to Git.
- `05-exports/` — generated exchange products; normally excluded from Git.

Prefer manifests, checksums, metadata, and retrieval instructions over committing
large GIS datasets. Keep sensitive or restricted payloads outside this repository.
