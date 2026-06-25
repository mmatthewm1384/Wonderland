# rootless-services-reconcile

ROOT=/Users/wonderland/Wonderland
COMPOSE=/Users/wonderland/Wonderland/docker/compose.yml

## lima
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49245    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Running    127.0.0.1:49376    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

## compose authority

## post containers
wl-sandbox docker.io/library/alpine:latest Up
wl-chatgpt-keyless docker.io/library/wl-chatgpt-keyless-wl-chatgpt-keyless:latest Created
wl-grok-keyless docker.io/library/wl-grok-keyless-wl-grok-keyless:latest Created
veil-veil-run-9d584865a610 docker.io/library/veil-veil:latest Created
wl-grafana docker.io/grafana/grafana:11.1.4 Up
wl-prometheus docker.io/prom/prometheus:latest Up
wl-loki docker.io/grafana/loki:latest Up
wl-nats docker.io/library/nats:2-alpine Up
wl-dns docker.io/coredns/coredns:latest Up
wl-portainer docker.io/portainer/portainer-ce:alpine Created
wl-torrent-client lscr.io/linuxserver/qbittorrent:latest Created
wl-torrent-vpn docker.io/qmcgaw/gluetun:v3 Created
wl-seed docker.io/library/python:3.12-alpine Created
wl-document-cleaner docker.io/library/document-cleaner-wl-document-cleaner:latest Created
wl-anon-scraper docker.io/library/alpine:3.18 Up
wl-anon-tor docker.io/library/alpine:3.18 Up

## required service status
PASS wl-dns
PASS wl-nats
PASS wl-loki
PASS wl-prometheus
PASS wl-grafana

REPORT=/Users/wonderland/Wonderland/vault/08-Operations/reports/rootless-services-reconcile-20260625-062504.md
