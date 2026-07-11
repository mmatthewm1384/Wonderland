# Wonderland Platform Engine

The Platform Engine is the orchestration boundary for Wonderland subsystem
verification and certification.

## Responsibilities

- import and validate the canonical `wlcli` command registry;
- invoke subsystem-owned verification interfaces;
- normalize subsystem results;
- calculate the Platform engineering gate;
- emit stable text and JSON reports;
- produce independently verifiable certification evidence.

## Non-responsibilities

The Platform Engine does not implement Runtime, Builder, Governance, Mirror,
Academy, or Architecture behavior. Each subsystem remains authoritative for its
own implementation and verification.

## Commands

```text
wl platform verify
wl platform verify --json
wl platform verify --verbose
wl platform verify --include-optional
wl platform certify
Mirror and Academy are optional until their convergence milestones are complete.
