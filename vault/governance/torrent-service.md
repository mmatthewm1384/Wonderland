# Torrent Service Governance

## Service

wl-torrent

## Components

* Gluetun VPN
* Surfshark WireGuard
* qBittorrent WebUI

## Secrets

Stored in:

* vault/secrets/vpn.env
* vault/secrets/torrent.env

## Recovery

### VPN

1. Generate new Surfshark WireGuard profile.
2. Update vault/secrets/vpn.env.
3. Run:
   wl torrent down
   wl torrent repair

### WebUI Credentials

1. Update vault/secrets/torrent.env.
2. Login to qBittorrent.
3. Change password in WebUI.
4. Update secret record.

## Verification

wl torrent doctor

Expected:

* PASS vpn.env
* PASS vpn container
* PASS client container

## Export

wl torrent export

Exports runtime downloads and generates manifest.sha256.
