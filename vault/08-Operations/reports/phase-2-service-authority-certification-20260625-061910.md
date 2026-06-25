# phase-2-service-authority-certification

Thu Jun 25 06:19:10 PDT 2026

## services reconcile
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

## reconcile compose services
COMPOSE /Users/wonderland/Wonderland/ephemeral/compose/matrix-atom-slam
COMPOSE /Users/wonderland/Wonderland/ephemeral/services/wl-sandbox

## post containers
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

## required service status
FAIL wl-dns
FAIL wl-nats
FAIL wl-loki
FAIL wl-prometheus
PASS wl-grafana

REPORT=/Users/wonderland/Wonderland/vault/08-Operations/reports/rootless-services-reconcile-20260625-061910.md

## status
Wonderland Status
=================

Universe
FAIL universe             

Lima
WARN default legacy unavailable 
PASS wonderland-rootless  

Services
FAIL wl-dns               
FAIL wl-nats              
FAIL wl-loki              
FAIL wl-prometheus        
PASS wl-grafana           

Storage
PASS authority            external optional in light mode

Governance
PASS governance           

Doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
FAIL universe                 +0
PASS lima-default             +10
PASS rootless                 +10
FAIL dns                      +0
FAIL nats                     +0
PASS loki                     +10
FAIL prometheus               +0
PASS grafana                  +10

Health Score: 60/100
RESULT FAIL

## doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
FAIL universe                 +0
PASS lima-default             +10
PASS rootless                 +10
FAIL dns                      +0
FAIL nats                     +0
PASS loki                     +10
FAIL prometheus               +0
PASS grafana                  +10

Health Score: 60/100
RESULT FAIL
