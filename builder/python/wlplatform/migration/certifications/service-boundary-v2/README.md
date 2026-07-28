# Wonderland Platform Service Boundary Migration v2

Status: Certified

## Objective

Separate orchestration from capability ownership.

## Canonical Service Ownership

The following packages own service implementations:

- wlplatform.platform
- wlplatform.runtime
- wlplatform.governance
- wlplatform.registry
- wlplatform.telemetry

## Composition Boundary

The package:

wlplatform.services


only exposes canonical services.

It contains no capability implementations.

## Maintenance

MaintenanceService provides:

- service discovery
- health validation
- readiness reporting

## Migration Backup

Previous duplicate implementations are preserved under:


migration/backups/service-duplicates/


## Validation

Verified:

- canonical service imports
- maintenance service execution
- duplicate implementation removal
- contract boundary separation
