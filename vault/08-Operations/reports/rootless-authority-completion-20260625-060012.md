# rootless-authority-completion

Thu Jun 25 06:00:12 PDT 2026

## Doctor
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

## Status
Wonderland Status
=================

Universe
FAIL universe             

Lima
PASS default legacy       
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

## Runtime Registry
{
  "id": "rootless-runtime",
  "authority": "wonderland-rootless",
  "legacy": "default",
  "state": "certified",
  "latest_report": "/Users/wonderland/Wonderland/vault/08-Operations/reports/runtime-lifecycle-drill-20260625-055606.md",
  "certified_at": "2026-06-25T12:57:00Z",
  "checks": [
    "wl-verify-rootless-runtime",
    "wl-verify-runtime-lifecycle",
    "wl-verify-paths",
    "wl doctor",
    "wl status"
  ]
}

## Runtime Index
{
  "id": "runtime-certification-index",
  "generated_at": "2026-06-25T12:57:01Z",
  "rootless_runtime": "",
  "runtime_lifecycle": "",
  "runtime_registry_recovery": "",
  "rootless_recovery": "",
  "registry": "/Users/wonderland/Wonderland/vault/05-Registry/runtime/rootless-runtime.json"
}
