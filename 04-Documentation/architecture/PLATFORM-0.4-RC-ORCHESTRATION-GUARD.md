# Platform 0.4 RC Orchestration Guard

## Purpose

The orchestration guard prevents high-level platform commands from recursively invoking other high-level platform wrappers.

## Rule

Certification, finalization, and status commands should call lower-level gates, not each other.

## Command

```bash
bin/wl-platform-orchestration-guard
Policy

No destructive changes.

This is a stabilization guard only.
