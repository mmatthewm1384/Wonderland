# PORTLAND — A Living City Architecture

**Working philosophy:** Engineered with Purpose. Crafted with Soul.  
**Project status:** Draft / Proposed  
**Target workspace:** `projects/portland/`  
**Epistemic rule:** KNOWN · DERIVED · PROPOSED · SPECULATIVE · UNKNOWN

PORTLAND is an evidence-led study and architectural vision for the real city of
Portland, Oregon. It is not a blank-canvas redevelopment exercise and is not a
subproject of XCAVIER or the Chronos-Stasis Enclave.

## Start here

1. Read `docs/00-governance/README.md`.
2. Read `docs/01-architecture/README.md`.
3. Review `config/project.yaml`.
4. Follow `docs/04-research/README.md` before collecting or transforming data.
5. Use the domain workstream README before creating domain deliverables.

## Repository principles

- Preserve evidence, provenance, uncertainty, and historical revisions.
- Never present a proposal or speculative scenario as an existing condition.
- Declare geography, time period, coordinate reference system, units, and method.
- Do not commit licensed, sensitive, personal, or restricted source data without
  an explicit review of rights, security, and retention.
- Treat `data/00-incoming/` as a controlled intake area, not a general dump.
- Keep large source datasets outside Git unless an explicit data-governance
  decision authorizes versioning. Commit manifests and reproducible metadata.
- Do not mint global document IDs locally. GDIR registration is a separate,
  governed action.
- Generated maps, reports, and exports are derivatives unless explicitly
  designated otherwise.

## Repository map

| Path | Responsibility |
|---|---|
| `docs/` | Canonical project documentation |
| `domains/` | Workstream specifications, research, and outputs |
| `data/` | Governed spatial and tabular data lifecycle |
| `models/` | Analytical models, simulations, and model contracts |
| `maps/` | Cartographic projects, styles, and map outputs |
| `evidence/` | Validation, review, acceptance, and audit records |
| `schemas/` | Versioned machine-readable contracts |
| `registries/` | Project-local indexes and adapters; not global identity authorities |
| `scripts/` | Reproducible utilities and pipelines |
| `tests/` | Validation code and synthetic fixtures |
| `config/` | Project configuration and controlled vocabularies |

## Initial execution sequence

1. Establish repository and governance controls.
2. Inventory authoritative geographic boundaries and coordinate systems.
3. Build GEO-001 baseline before dependent domain analysis.
4. Establish evidence, source, and dataset registers.
5. Proceed to HYD-001, CLI-001, ECO-001, and HIS-001 with explicit dependencies.

See `docs/00-governance/REPOSITORY-BOOTSTRAP.md` for setup and acceptance checks.
