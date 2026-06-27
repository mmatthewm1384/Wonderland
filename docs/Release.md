
Wonderland Release Process
Build
wl-release build

The build performs:

Python compile check.
Unit tests.
Schema validation.
OpenAPI validation.
API readiness check.
Drift check.
Metrics check.
Package creation.
Package verification.
Release Artifacts
runtime/release/certification-latest.json
runtime/release/manifest-latest.json
runtime/release/wonderland-platform-latest.tar.gz
Freeze
wl-platform-freeze

Freeze writes a certification record under:

vault/05-Registry/certifications/

