# wonderland-phase-2-completion

Thu Jun 25 09:43:21 PDT 2026

## wl doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
PASS universe                 +10
PASS lima-default             +10
PASS rootless                 +10
PASS dns                      +10
PASS nats                     +10
PASS loki                     +10
PASS prometheus               +10
PASS grafana                  +10

Health Score: 100/100
RESULT PASS

## wl status
Wonderland Status
=================

Universe
PASS universe

Lima
WARN default legacy unavailable
PASS wonderland-rootless primary

Services
PASS wl-dns
PASS wl-nats
PASS wl-loki
PASS wl-prometheus
PASS wl-grafana

Storage
Wonderland Storage Authority

Volume:      T7_Wonderland
Path:        /Volumes/T7_Wonderland
Mounted:     YES
Size:        931Gi
Used:        329Gi
Available:   602Gi
Use:         36%
State:       ATTACHED

Governance
PASS governance

Doctor
Wonderland Doctor

PASS storage                  +10
PASS governance               +10
PASS universe                 +10
PASS rootless                 +10
PASS dns                      +10
PASS nats                     +10
PASS loki                     +10
PASS prometheus               +10
PASS grafana                  +10
PASS registry                 +10

Health Score: 100/100
RESULT PASS

## lima
NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR
default                Running    127.0.0.1:49245    vz        aarch64    4       4GiB      100GiB    ~/.lima/default
wonderland-rootless    Running    127.0.0.1:49376    vz        aarch64    4       6GiB      80GiB     ~/.lima/wonderland-rootless

## containers
wl-sandbox docker.io/library/alpine:latest Up
wl-grafana docker.io/grafana/grafana:11.1.4 Up
wl-prometheus docker.io/prom/prometheus:latest Up
wl-loki docker.io/grafana/loki:latest Up
wl-nats docker.io/library/nats:2-alpine Up
wl-dns docker.io/coredns/coredns:latest Up
wl-anon-scraper docker.io/library/alpine:3.18 Up
wl-anon-tor docker.io/library/alpine:3.18 Up
