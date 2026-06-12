# WL-GOV-005 — Backup Certification Standard

## Status

Active

## Purpose

A backup is not considered recoverable until it has been verified and restore-tested.

## Certification Requirements

A certified backup must:

1. Complete successfully
2. Generate a manifest
3. Pass checksum verification
4. Pass restore drill verification
5. Be recorded in a backup registry

## Required Commands

```bash
wl authority backup
wl authority verify-backup
wl authority restore-drill
Certification State

UNCERTIFIED
Backup exists but has not been tested.

CERTIFIED
Backup exists, verifies, and passes restore drill.

Principle

Runtime state is disposable.
Authority is not.
