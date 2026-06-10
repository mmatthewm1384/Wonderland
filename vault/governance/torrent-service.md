# WL-TORRENT SERVICE GOVERNANCE

## Identity

- Service ID: wl-torrent
- Type: Infrastructure Service
- Status: Candidate
- Authority: Operator
- Version: 1

---

## Purpose

Provide VPN-isolated torrent acquisition, quarantine, verification, and export workflows for legal content inside the Wonderland ecosystem.

---

## Authority

### Configuration Authority

```text
vault/secrets/vpn.env
Service Definition
services/torrent/compose.yml
Command Authority
bin/wl-torrent
bin/wl-torrent-export
Dependencies
Required
nerdctl rootless runtime
Gluetun
qBittorrent
Surfshark WireGuard profile
vault/secrets/vpn.env
Runtime
Containers
wl-torrent-vpn
wl-torrent-client
Volumes
torrent_wl-torrent-config
torrent_wl-torrent-downloads
Local WebUI
http://127.0.0.1:9091/
Verification
wl torrent doctor
curl -I http://127.0.0.1:9091/

Expected:

PASS vpn.env
PASS downloads
PASS watch
PASS vpn container
PASS client container
HTTP/1.1 200 OK
Recovery
Standard Recovery
wl torrent repair
Full Recovery
wl torrent down
wl torrent repair
wl torrent doctor
Export
wl torrent export

Output:

vault/data/torrents/downloads-export/
vault/data/torrents/downloads-export/manifest.sha256
Failure Modes
VPN Failure

Symptoms:

wl-torrent-vpn is missing or unhealthy.
Gluetun cannot report a public VPN IP.
qBittorrent client cannot start because VPN namespace is unavailable.

Recovery:

wl torrent down
wl torrent repair
wl torrent doctor
Client Failure

Symptoms:

wl-torrent-client is missing.
WebUI unavailable.
Export has no source volume.

Recovery:

wl torrent repair
curl -I http://127.0.0.1:9091/
Secret Failure

Symptoms:

Missing vault/secrets/vpn.env.
Empty WireGuard values.
Surfshark profile revoked or expired.

Recovery:

Generate new Surfshark WireGuard profile.
Update vault/secrets/vpn.env.
Run:
wl torrent down
wl torrent repair
wl torrent doctor
Governance

This service may be destroyed and rebuilt without loss of authority.

Authority resides in:

vault/
service definitions
recovery procedures

Runtime state is disposable.
Authority is not.
