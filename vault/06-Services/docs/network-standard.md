
Network Standard
<!-- id: network-standard-v4 -->
Rule

Service networks must be explicit, named, and recoverable.

Naming

Preferred:

wonderland-<name>

Allowed for service-local networks:

wl-<name>-network
Anon Network
wl-anon-network

Used by:

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
