# Wonderland Firewall Policy

## Overview

Wonderland Firewall Policy v1 defines the intended local-first network exposure posture.

This phase is report-only. It does not modify macOS `pf`, Linux `nftables`, Docker, or nerdctl networking.

## Defaults

```text
inbound: deny
outbound: allow
Commands
wl firewall verify
wl firewall report
Design Decision

Firewall enforcement should not be enabled until service discovery, recovery access, and local operator override are implemented and tested.
