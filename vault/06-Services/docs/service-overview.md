
Service Overview
<!-- id: service-overview-v4 -->
Purpose

This layer defines Wonderland-managed services.

Managed Services

A managed service must have:

Service definition
Runtime name
Verification command
Recovery command
Rollback path
Registry entry
Current Runtime

Known runtime services include:

wl-dns
wl-nats
wl-prometheus
wl-grafana
wl-loki
wl-anon-tor
wl-anon-scraper
Status

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
