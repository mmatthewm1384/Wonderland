# Runtime Inventory
<!-- id: runtime-inventory-v4 -->

Runtime:
containerd

Engine:
nerdctl

Current service classes:

Infrastructure:
- wl-dns
- wl-nats

Observability:
- wl-prometheus
- wl-loki
- wl-grafana

Privacy:
- wl-anon-tor

Applications:
- wl-anon-scraper

Discovery command:
    wl services discover-runtime

Verification command:
    wl verify

state: active
version: 4

## Governance Principle

This component may be destroyed and rebuilt without loss of authority.

Authority resides in:

- documented intent
- service definitions
- recovery procedures
- version-controlled governance records

Runtime state is disposable.
Authority is not.
