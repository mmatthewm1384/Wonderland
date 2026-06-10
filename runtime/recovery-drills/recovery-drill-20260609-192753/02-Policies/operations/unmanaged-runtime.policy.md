# Unmanaged Runtime Policy
<!-- id: unmanaged-runtime-policy-v4 -->

## Rule

Containers that do not use the `wl-*` naming standard are treated as unmanaged runtime state.

## Observed But Not Governed

Unmanaged containers may be inventoried for awareness, but they are not controlled by Wonderland unless explicitly promoted.

## Promotion Requirement

To become Wonderland-managed, a container must have:

- `wl-*` service name
- Service definition
- Verification path
- Recovery path
- Rollback path
- Registry entry

## Status

state: active
version: 4
