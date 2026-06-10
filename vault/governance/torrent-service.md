Service: wl-torrent

Purpose:
VPN-isolated torrent acquisition service.

Authority:
vault/secrets/vpn.env

Runtime:
qBittorrent
Gluetun
WireGuard

Recovery:
wl torrent repair

Verification:
wl torrent doctor
curl -I http://127.0.0.1:9091/

Export:
wl torrent export
