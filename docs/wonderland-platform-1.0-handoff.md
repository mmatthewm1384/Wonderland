# Wonderland Platform 1.0 Handoff

## Status

Wonderland Platform 1.0 is certified operational.

## Runtime

- Runtime: `wonderland-rootless`
- Container runtime: rootless `nerdctl` through Lima
- Legacy Lima `default` is not part of normal operation

## Control Plane

- Controller API: `http://127.0.0.1:9105`
- Dashboard: `http://127.0.0.1:9110`
- API version: `/api/v1`
- Controller version: `3.0.0`
- Platform state schema: `1`

## Primary Commands

```zsh
wl-controller-v2 status
wl-release build
wl-platform-freeze
wl-dashboard
API Endpoints
GET /api/v1/version
GET /api/v1/ready
GET /api/v1/status
GET /api/v1/state
GET /api/v1/services
GET /api/v1/events
GET /api/v1/timeline
GET /api/v1/drift
GET /api/v1/metrics
Dashboard
http://127.0.0.1:9110

Dashboard is a read-only client of the controller API.

Certified Components
Registry
Desired State
PlatformState
Service Model
Runtime Adapter
Scheduler
Event Bus
Timeline
Health Engine
Recovery Engine
Deployment Engine
Drift Engine
Metrics
REST API v1
Dashboard v1
Release Pipeline
Certification Pipeline
Release Artifacts
runtime/release/certification-latest.json
runtime/release/manifest-latest.json
runtime/release/wonderland-platform-latest.tar.gz
Certification
vault/05-Registry/certifications/wonderland-platform-1.0.json
Next Recommended Work
Add automated unit tests.
Add backup/restore.
Add policy engine.
Add plugin SDK.
Improve dashboard views.
Add documentation for operations and recovery.
