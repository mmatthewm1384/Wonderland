import base64
import json
import os

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric import ed25519


class VolatileStateLedger:
    def __init__(self):
        # Generate ephemeral Ed25519 keypair in RAM (volatiles only)
        self.private_key = ed25519.Ed25519PrivateKey.generate()
        self.public_key = self.private_key.public_key()
        self.ledger = []

        # Initialize genesis state
        self._commit_state(
            "GENESIS_INIT", {"status": "initialized", "entropy": os.urandom(16).hex()}
        )

    def _hash_state(self, state_data: dict) -> str:
        serialized = json.dumps(state_data, sort_keys=True).encode("utf-8")
        return (
            base64.b64encode(os.hashlib.sha256(serialized).digest()).decode("utf-8")
            if hasattr(os, "hashlib")
            else base64.b64encode(__import__("hashlib").sha256(serialized).digest()).decode("utf-8")
        )

    def _commit_state(self, action: str, payload: dict):
        prev_hash = self.ledger[-1]["state_hash"] if self.ledger else "0" * 44

        entry = {
            "index": len(self.ledger),
            "prev_hash": prev_hash,
            "action": action,
            "payload": payload,
        }

        state_hash = self._hash_state(entry)
        signature = base64.b64encode(self.private_key.sign(state_hash.encode("utf-8"))).decode(
            "utf-8"
        )

        signed_entry = {**entry, "state_hash": state_hash, "signature": signature}

        self.ledger.append(signed_entry)
        return signed_entry

    def transition(self, action: str, payload: dict):
        return self._commit_state(action, payload)

    def verify_ledger(self) -> bool:
        self.public_key.public_bytes(
            encoding=__import__(
                "cryptography.hazmat.primitives.serialization", fromlist=["Encoding"]
            ).Encoding.Raw,
            format=__import__(
                "cryptography.hazmat.primitives.serialization", fromlist=["PublicFormat"]
            ).PublicFormat.Raw,
        )

        for i, entry in enumerate(self.ledger):
            # Verify chain linkage
            if i > 0 and entry["prev_hash"] != self.ledger[i - 1]["state_hash"]:
                return False

            # Verify Ed25519 signature
            sig = base64.b64decode(entry["signature"])
            h_val = entry["state_hash"].encode("utf-8")
            try:
                self.public_key.verify(sig, h_val)
            except InvalidSignature:
                return False
        return True


if __name__ == "__main__":
    ledger = VolatileStateLedger()
    ledger.transition("SPARK_BOOT", {"vm": "debian-slim", "cpu": 2})
    ledger.transition("EXECUTE_PAYLOAD", {"task": "verify_manifest"})

    print(f"[+] Ledger entries committed: {len(ledger.ledger)}")
    print(f"[+] Cryptographic integrity verified: {ledger.verify_ledger()}")
