#!/usr/bin/env python3
"""
AetherTrap — Anomalous Telemetry & Noise Event Capture
Platform: Wonderland / Aether Mesh HUD
"""

import hashlib
import json
import os
import time
from datetime import UTC, datetime

WORKSPACE_ROOT = os.environ.get("WONDERLAND_ROOT", "/Users/Wonderland/wonderland")
CRYSTAL_DIR = os.path.join(WORKSPACE_ROOT, "crystals", "aether_traps")
AURA_ACCENT_HEX = "#B00040"


class AetherTrap:
    def __init__(self, sensitivity_threshold: float = 4.0):
        self.threshold = sensitivity_threshold
        self.baseline_noise = 0.012
        self.samples_processed = 0
        self.trapped_events = []
        os.makedirs(CRYSTAL_DIR, exist_ok=True)

    def process_frame(
        self, frame_id: int, signal_amplitude: float, phase_coherence: float
    ) -> dict | None:
        """
        Evaluates incoming Aether frame against baseline thresholds.
        Fails closed on phase collapse or hyper-variance spikes.
        """
        self.samples_processed += 1
        variance = abs(signal_amplitude - self.baseline_noise)

        # Detection condition: Extreme variance OR severe phase anomaly
        if variance > (self.baseline_noise * self.threshold) or phase_coherence < 0.15:
            event = {
                "frame_id": frame_id,
                "timestamp_utc": datetime.now(UTC).isoformat(),
                "signal_amplitude": round(signal_amplitude, 6),
                "phase_coherence": round(phase_coherence, 6),
                "variance_sigma": round(variance / self.baseline_noise, 2),
                "status": "TRAPPED",
            }
            return self._seal_event(event)

        # Adaptive baseline update
        self.baseline_noise = (self.baseline_noise * 0.99) + (signal_amplitude * 0.01)
        return None

    def _seal_event(self, event: dict) -> dict:
        """Applies cryptographic SHA-256 seal to captured event."""
        payload = json.dumps(event, sort_keys=True).encode("utf-8")
        digest = hashlib.sha256(payload).hexdigest()
        event["crystal_hash"] = digest

        filename = f"trap_evt_{int(time.time())}_{digest[:8]}.json"
        filepath = os.path.join(CRYSTAL_DIR, filename)

        with open(filepath, "w") as f:
            json.dump(event, f, indent=2)

        self.trapped_events.append(filepath)
        return event


if __name__ == "__main__":
    trap = AetherTrap(sensitivity_threshold=3.5)
    print("[\033[38;2;176;0;64mAETHER_TRAP\033[0m] Ingestion engine active. Monitoring mesh...")

    # Verification test frames (Simulated signal stream)
    test_stream = [
        (101, 0.013, 0.98),
        (102, 0.011, 0.95),
        (103, 0.089, 0.11),  # Anomaly target 1
        (104, 0.014, 0.97),
        (105, 0.142, 0.04),  # Anomaly target 2
    ]

    for fid, amp, coherence in test_stream:
        captured = trap.process_frame(fid, amp, coherence)
        if captured:
            print(
                f"[\033[38;2;176;0;64mCAPTURED\033[0m] Frame {captured['frame_id']} | Hash: {captured['crystal_hash'][:12]} | Sigma: {captured['variance_sigma']}x"
            )
