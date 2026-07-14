#!/usr/bin/env python3
"""Smoke test for Wonderland Runtime BootScene."""

from __future__ import annotations

from wl.runtime.kernel import RuntimeKernel, RuntimeKernelConfig
from wl.runtime.scenes.boot import BootScene


def main() -> int:
    kernel = RuntimeKernel(
        config=RuntimeKernelConfig(
            frame_delay=0.03,
            max_frames=60,
        )
    )
    return kernel.run(BootScene())


if __name__ == "__main__":
    raise SystemExit(main())
