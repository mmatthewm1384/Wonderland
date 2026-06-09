# Service Recovery Standard

Purpose:
Defines how Wonderland services are restored after failure.

Recovery Order:

1. Network
2. Storage
3. DNS
4. Messaging
5. Observability
6. Applications

DNS Verification Command:

    wl runtime inspect wl-dns

Messaging Verification Command:

    wl runtime inspect wl-nats

Privacy Verification Command:

    wl anon doctor

State: active
Version: 4
