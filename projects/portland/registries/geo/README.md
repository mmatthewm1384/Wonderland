# GEO Registries

Project-local registries for the PORTLAND GEO workstream.

| Registry | Local key | Purpose |
|---|---|---|
| datasets.yaml | GDS | Dataset discovery and lifecycle |
| sources-evidence.yaml | GEV | Sources, evidence, methods and claims |
| boundaries.yaml | GBD | Geographic boundary provenance |

## Authority and synchronization

The corresponding Notion registries are the governance and knowledge records.
These YAML files are local, version-controlled working exports.

Notion domain home:
https://app.notion.com/p/41498c297ce28187a5efc9e41b6a0ae7

Notion dataset registry:
https://app.notion.com/p/251c7acf42cb4ac496053494746dce1c

Notion source and evidence registry:
https://app.notion.com/p/69a75532c9c64b418de5d63a10fb9197

Notion boundary registry:
https://app.notion.com/p/7d3f750f52ce41e79c621fd0266c8019

GEO-001:
https://app.notion.com/p/41398c297ce28118b151f47529f4cfe2

These local keys are project-local references, not Wonderland GDIR identities.

## Lifecycle vocabulary

- Discovered: source identified; not necessarily acquired.
- Acquired: payload obtained and acquisition recorded.
- Validated: integrity and metadata checks completed.
- Accepted: passed documented review and acceptance.
- Rejected: unsuitable for the declared purpose.
- Superseded: replaced by a newer or more authoritative record.

Never infer acquisition, validation, or acceptance from discovery.

## Data handling

Bulk spatial payloads do not belong in these registries.
Store manifests, checksums, source metadata, lineage, and retrieval
instructions here. Keep restricted and licensed payloads in approved storage.

## Synchronization

Every synchronization from Notion must record:
- Export timestamp (UTC)
- Source page or database
- Source record identifiers
- Exporter or method
- Record count
- Content checksum

No automated bidirectional synchronization is implied.
