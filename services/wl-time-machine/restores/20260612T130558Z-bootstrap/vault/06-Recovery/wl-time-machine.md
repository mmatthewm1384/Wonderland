# wl-time-machine

## Purpose

wl-time-machine creates append-only local Wonderland snapshots with manifests and checksum verification.

## Safety Model

Live files are never overwritten by restore.

Restore is staged only:

    bin/wl-time-machine restore-stage latest

The operator reviews staged files before manual recovery.

## Commands

    bin/wl-time-machine init
    bin/wl-time-machine status
    bin/wl-time-machine snapshot manual
    bin/wl-time-machine list
    bin/wl-time-machine verify
    bin/wl-time-machine verify <snapshot-id>
    bin/wl-time-machine restore-stage latest
    bin/wl-time-machine recovery-bundle

## Recovery

    bin/wl-time-machine list
    bin/wl-time-machine verify latest
    bin/wl-time-machine restore-stage latest

## Rollback

    git restore bin/wl-time-machine services/wl-time-machine vault/06-Recovery/wl-time-machine.md
