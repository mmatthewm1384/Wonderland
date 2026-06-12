
Observability Standard
<!-- id: observability-standard-v4 -->
Rule

Wonderland services should expose enough state to diagnose failure.

Required Signals
Health
Status
Logs
Metrics
Configuration path
Runtime path
Dependency state
Preferred Stack
Prometheus
Grafana
Loki
NATS
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
