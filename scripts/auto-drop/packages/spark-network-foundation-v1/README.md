# spark-network-foundation-v1

Canonical Spark networking/deployment foundation.

## Contract

- Alpine guest networking is owned by `ifupdown-ng`.
- `lo` is loopback.
- `eth0` uses DHCP.
- OpenRC enables networking, sshd, and the Lima guest agent.
- The host uses a generated Lima profile under `profiles/`.
- A missing Lima instance is created explicitly with `limactl create --name=...`; it is never allowed to fall back to `template:default`.
- Host paths are never passed into the Debian factory. Factory paths use `/mnt/wonderland`.
- Evidence is written under `vault/08-Operations/evidence/spark-network-foundation/<spark-id>/`.

## Usage

From the Wonderland repository:

```bash
scripts/auto-drop/packages/spark-network-foundation-v1/install.sh spark-matthew-001
scripts/auto-drop/packages/spark-network-foundation-v1/verify.sh spark-matthew-001
```

Rollback:

```bash
scripts/auto-drop/packages/spark-network-foundation-v1/rollback.sh spark-matthew-001
```

The installer is intentionally conservative: it requires the canonical Spark image to exist, snapshots the pre-change image, stops/deletes an existing instance before image mutation, mutates only the guest network configuration, generates the canonical profile, creates the instance explicitly, and verifies SSH plus guest networking.
