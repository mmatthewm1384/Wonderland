# Tier 2 Operational Registry: Core Service Catalog

## Authorized System Inventory
The following catalog maps the explicitly permitted platform services within the Wonderland ecosystem. Any service running in Tier 3 that is absent from this registry represents an unauthorized drift state.

| Service Name | Namespace | Execution Profile | Boundary Type |
| :--- | :--- | :--- | :--- |
| `vault` | `governance` | Core Intelligence Vault | Local Storage |
| `tui` | `operations` | Terminal Control Dashboard | Interactive CLI |
| `micro-vm` | `compute` | Kernel-backed Sandbox Environment | Hypervisor Isolation |

## Registration Protocol
To append services to this inventory matrix, an architecture spec update must be approved by the Operator (**Matthew Mahaney**).
