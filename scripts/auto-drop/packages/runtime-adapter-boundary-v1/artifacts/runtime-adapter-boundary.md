# Runtime Adapter Boundary v1

## Contract

RuntimeService owns lifecycle.

RuntimeAdapter owns runtime execution.

Supported adapters:

- Lima
- nerdctl

The CLI never calls adapters directly.
