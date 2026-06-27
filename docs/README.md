# Wonderland Platform

Wonderland is a local, rootless, API-driven control plane for managing the Wonderland service runtime.

## Core URLs

```text
Controller API: http://127.0.0.1:9105/api/v1
Dashboard:      http://127.0.0.1:9110
OpenAPI:        http://127.0.0.1:9105/api/v1/openapi.json
Primary Commands
wl-unified status
wl-unified state
wl-unified config
wl-unified policy
wl-unified schema
wl-unified openapi
wl-unified test
wl-unified release build
wl-unified backup create
wl-dashboard
Release Baseline

The current platform baseline includes:

Controller kernel
Runtime adapter
Typed service model
Scheduler
Policy engine
Health, recovery, deployment, and drift engines
REST API v1
Dashboard
OpenAPI contract
Plugin SDK
Python SDK
Release pipeline
Backup tooling
Schema validation
Automated tests
