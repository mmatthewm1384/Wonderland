# wonderland-phase-3-completion

Thu Jun 25 10:08:02 PDT 2026

## paths
PASS no active source hardcoded authority paths

## doctor
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

## status
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
FAIL phase3-authority         +0

Health Score: 100/110
RESULT FAIL
