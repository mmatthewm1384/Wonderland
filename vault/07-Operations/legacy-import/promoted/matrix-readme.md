# Matrix Relay Compose

## Status

Sanitized candidate.

## Runtime Status

Do not run yet.

## Required Review

- Domains
- Federation
- Synapse secrets
- Postgres credentials
- Element config
- Cloudflared settings

## Sanitization

Cloudflared tunnel service removed from sanitized candidate.

Reason:

- Requires external token
- Contains `CLOUDFLARED_TOKEN`
- Should be redesigned later as an optional Relay ingress profile
