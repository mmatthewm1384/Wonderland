
Wonderland Architecture
Overview

Wonderland is structured as a local control-plane platform.

Dashboard / CLI / SDK
        │
        ▼
REST API v1
        │
        ▼
Controller Kernel
        │
        ├── PlatformState
        ├── Scheduler
        ├── Registry
        ├── Policy
        ├── Health
        ├── Recovery
        ├── Deployment
        ├── Drift
        ├── Metrics
        ├── Events
        └── Timeline
        │
        ▼
Runtime Adapter
        │
        ▼
Lima + rootless nerdctl
Design Principles
Registry is authoritative.
Desired state is declarative.
Controller owns orchestration.
CLI, dashboard, and SDK are clients.
Events are append-only.
Timeline is immutable.
PlatformState is the operational model.
Policies express operational intent.
Rootless runtime is the only supported runtime.
