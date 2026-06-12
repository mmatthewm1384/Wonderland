# wl-roam

## Purpose

`wl-roam` is the MacBook-only Wonderland roaming network layer.

It detects the current authorized network, records state, enforces trust, queues work while offline, and syncs only when the current network is trusted.

## Boundary

`wl-roam` never cracks, harvests, spoofs, bypasses, or joins networks without authorization.

## Commands

```bash
wl-roam init
wl-roam status
wl-roam trust-current
wl-roam forget <ssid>
wl-roam queue "message"
wl-roam sync
wl-roam audit
wl-roam doctor
wl-roam recovery
Trust Model

Trusted SSIDs are stored in:
services/wl-roam/config/trusted-networks.txt
Sync is blocked unless:
internet = PASS
trusted = true
State

Current network state:
services/wl-roam/state/current-network.json
Network history:
services/wl-roam/state/network-history.log
Recovery

Run:
wl-roam recovery
This refreshes state, renews DHCP, and reruns status.

Rollback
git restore bin/wl-roam bin/wl-roam-* services/wl-roam vault/04-Network/wl-roam.md
