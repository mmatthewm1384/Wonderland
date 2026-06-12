# Wonderland Command Catalog

Generated: `2026-06-10T09:38:47`

## `wl doctor`

- Category: `core`
- Status: `active`
- Purpose: Run promoted Wonderland verification checks.
- Inputs: none
- Outputs: PASS/FAIL health report
- Verification: vault, registry, runtime drift, operations, intelligence, governance, recovery
- Recovery: wl repair

## `wl health`

- Category: `core`
- Status: `active`
- Purpose: Show concise operational dashboard.
- Inputs: none
- Outputs: summary health status
- Verification: wl doctor
- Recovery: wl doctor

## `wl operations verify`

- Category: `operations`
- Status: `active`
- Purpose: Verify operations-layer documents, registries, and standards.
- Inputs: vault/07-Operations
- Outputs: operations verification result
- Verification: required operations artifacts exist
- Recovery: restore missing operation artifacts from snapshot

## `wl runtime drift`

- Category: `runtime`
- Status: `active`
- Purpose: Compare expected registered containers against actual runtime containers.
- Inputs: vault/06-Services/service-registry.json, nerdctl ps
- Outputs: vault/07-Operations/drift/runtime-drift.json
- Verification: missing=0, unmanaged=0, unexpected_wl=0
- Recovery: start missing services, stop unexpected services, update registry only after review

## `wl snapshot`

- Category: `recovery`
- Status: `active`
- Purpose: Create recoverable point-in-time vault snapshot.
- Inputs: vault
- Outputs: snapshot archive, sha256 checksum
- Verification: wl verify-snapshot
- Recovery: wl restore

## `wl verify-snapshot`

- Category: `recovery`
- Status: `active`
- Purpose: Verify snapshot integrity.
- Inputs: snapshot archive, sha256 checksum
- Outputs: snapshot verification result
- Verification: checksum match, archive readable
- Recovery: create new snapshot, restore prior valid snapshot

## `wl service list`

- Category: `services`
- Status: `planned`
- Purpose: List registered Wonderland services.
- Inputs: vault/06-Services/service-registry.json
- Outputs: service list
- Verification: registry integrity
- Recovery: wl registry verify

## `wl service show <name>`

- Category: `services`
- Status: `planned`
- Purpose: Show one service definition and runtime mapping.
- Inputs: service name
- Outputs: service definition summary
- Verification: definition exists
- Recovery: repair or restore service definition

## `wl service promote <name>`

- Category: `services`
- Status: `planned`
- Purpose: Promote a verified service into the Wonderland control plane.
- Inputs: service definition, doctor result, audit evidence
- Outputs: registry update, promotion record
- Verification: doctor passes, runtime drift clean, registry integrity
- Recovery: wl service rollback <name>
