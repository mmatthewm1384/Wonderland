# rootless-services-reconcile

ROOT=/Users/wonderland/Wonderland

## lima
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49245    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Running    127.0.0.1:49376    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

## current containers
wl-sandbox Up
wl-chatgpt-keyless Created
wl-grok-keyless Created
veil-veil-run-9d584865a610 Created
wl-grafana Up
wl-prometheus Created
wl-loki Created
wl-nats Created
wl-dns Created
wl-portainer Created
wl-torrent-client Created
wl-torrent-vpn Created
wl-seed Created
wl-document-cleaner Created
wl-anon-scraper Up
wl-anon-tor Up

## start existing certified containers
START existing wl-dns
wl-dns
START existing wl-nats
wl-nats
START existing wl-loki
wl-loki
START existing wl-prometheus
wl-prometheus
PASS already running wl-grafana

## post containers
wl-sandbox Up
wl-chatgpt-keyless Created
wl-grok-keyless Created
veil-veil-run-9d584865a610 Created
wl-grafana Up
wl-prometheus Up
wl-loki Up
wl-nats Up
wl-dns Up
wl-portainer Created
wl-torrent-client Created
wl-torrent-vpn Created
wl-seed Created
wl-document-cleaner Created
wl-anon-scraper Up
wl-anon-tor Up

## required service status
PASS wl-dns
PASS wl-nats
PASS wl-loki
PASS wl-prometheus
PASS wl-grafana

REPORT=/Users/wonderland/Wonderland/vault/08-Operations/reports/rootless-services-reconcile-20260625-062119.md
