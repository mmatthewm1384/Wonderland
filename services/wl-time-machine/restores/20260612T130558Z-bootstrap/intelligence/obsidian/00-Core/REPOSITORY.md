# Wonderland Repository Storage Architecture

## Storage Tier Enforcements
To keep tracking pure and completely prevent operational drift, data flow boundaries are divided across three separate directory tiers:

* **Tier 1 (Authoritative Core):** Located at `~/Wonderland/intelligence/obsidian`. Contains all immutable policies, technical specification documents, and cryptographic identity parameters.
* **Tier 2 (Operational Registry):** Holds context-generated inventory files, service manifests, and real-time environment configurations.
* **Tier 3 (Implementation Sandbox):** Located at `~/Wonderland/Wonderland-v4`. Houses all automation code frameworks, internal virtual environments (`.venv`), and service run scripts.
