---
system: Wonderland
operator:
  name: Matthew Mahaney
  authority: final

governance:
  source_of_truth: ~/Wonderland/intelligence/obsidian/00-Core
  governance_hub: ~/Wonderland/intelligence/obsidian/00-Core/Governance.md
  registry_mode: generated
  runtime_authority: governance

runtime:
  container_runtime: nerdctl
  compose_engine: nerdctl compose
  rootless: true

paths:
  root: ~/Wonderland
  bin: ~/Wonderland/bin
  core: ~/Wonderland/core
  intelligence: ~/Wonderland/intelligence/obsidian
  logs: ~/Wonderland/logs
  data: ~/Wonderland/data
  secrets: ~/Wonderland/secrets
  tools: ~/Wonderland/tools

commands:
  - wl-governance
  - wl-doctor
  - wl-disposable
  - wl-vault
  - wl-proxy
  - wl-status
  - wl-start
  - wl-stop
  - wl-snapshot

doctor:
  mandatory: true
  checks:
    - required directories
    - required files
    - dependencies
    - executable binaries
    - governance source
    - generated registry
    - logs

registry:
  generated: true
  file: ~/Wonderland/.wl-registry

principles:
  - persistence
  - recoverability
  - auditability
  - security
  - automation
  - versioning
  - modularity

services:
  - wl-governance
  - wl-registry
  - wl-doctor
  - wl-vault
  - wl-proxy

networks:
  - wonderland-core
  - wonderland-private
  - wonderland-services

volumes:
  - wl-governance-data
  - wl-registry-data
  - wl-vault-data
  - wl-logs-data

security:
  default_mode: private
  secrets_policy: references_only
  plaintext_secrets: forbidden
  audit_logging: required
  least_privilege: required

encryption:
  required: true
  at_rest: required
  in_transit: preferred
  secrets: external_or_encrypted
  registry_contains_secrets: false

privacy:
  personal_data_policy: minimize
  thought_content_policy: never_store_raw
  anonymize_identifiers: true
  generated_registry_redaction: required

anonymity:
  operator_identity: governed
  public_identity: minimized
  thought_records: prohibited
  derived_metadata_only: true
---

# Wonderland Governance

This file is the active governance hub for Wonderland.

The YAML frontmatter above is authoritative and machine-readable.

Human-readable policy and rationale follow below.

## Authority

Matthew Mahaney is the Operator and final authority for Wonderland.

## Registry Rule

Governance.md is authoritative.

.wl-registry is generated runtime state.

Policy drives runtime.

Runtime does not redefine policy.

## Runtime Rule

Wonderland uses nerdctl and containerd as the default container runtime model.

Docker is not the default runtime.

## Recovery Rule

No system is complete until it includes verification, recovery, and rollback.

## Architecture References

- [[knowledge-architecture]]

The Knowledge Architecture document defines the separation of knowledge, governance, generated state, execution, and recovery.
