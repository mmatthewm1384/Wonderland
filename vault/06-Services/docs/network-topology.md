# Network Topology
<!-- id: network-topology-v4 -->

Networks:

wl-anon-network

Purpose:
Privacy routing.

Services:
- wl-anon-tor
- wl-anon-scraper

wonderland-core

Purpose:
Primary service communication.

wonderland-observability

Purpose:
Metrics and logging.

Rule:
Services must not rely on implicit networking.
All service communication must occur through named networks.

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
