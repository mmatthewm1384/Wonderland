
Port Map
<!-- id: port-map-v4 -->
Known Ports
Service	Host Port	Container Port	Purpose
wl-grafana	3000	3000	Dashboard
wl-prometheus	9090	9090	Metrics
wl-loki	3100	3100	Logs
wl-nats	4222	4222	Message bus
wl-nats	8222	8222	Monitoring
wl-dns	1053	1053	DNS
wl-anon-tor	9050	9050	SOCKS5 Tor route
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
