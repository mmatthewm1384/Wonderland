---
title: Backup Baseline
type: recovery
status: draft
version: 1.0.0
parent: "[[recovery-standard]]"
tags:
  - recovery
  - backup
---

# Backup Baseline

> [!abstract]
> Defines minimum backup expectations for Wonderland-v4.

## Purpose

Backups provide recoverable state for documentation, repositories, service data, configuration, and critical operational records.

## Backup Classes

### Knowledge Backup

Obsidian vault and governance documentation.

### Repository Backup

Git remotes and local repository mirrors.

### Service Data Backup

Volumes, databases, object storage, and runtime state.

### Configuration Backup

Runtime manifests, environment templates, and non-secret configuration.

### Secret Recovery

Secret recovery procedures and encrypted secret stores.

## Minimum Backup Metadata

Each backup process must document:

- Source
- Destination
- Frequency
- Retention
- Restore procedure
- Verification procedure

## Verification Rule

> [!warning]
> A backup that has not been restored or verified is an assumption.

## Recovery Priority

1. Knowledge core
2. Governance and ADRs
3. Repositories
4. Secrets recovery
5. Platform configuration
6. Service data
7. Runtime services
