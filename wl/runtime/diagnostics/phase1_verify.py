"""Phase 1 Runtime Core verification."""

from __future__ import annotations

from wl.runtime.context import RuntimeContext
from wl.runtime.kernel import RuntimeKernel, RuntimeKernelConfig
from wl.runtime.layout import LayoutEngine, PlacedLine
from wl.runtime.renderer import Renderer
from wl.runtime.screen import Screen
from wl.runtime.scenes.boot import BootScene


def verify() -> int:
    checks = [
        ("RuntimeContext", RuntimeContext),
        ("Screen", Screen),
        ("LayoutEngine", LayoutEngine),
        ("Renderer", Renderer),
        ("RuntimeKernel", RuntimeKernel),
        ("RuntimeKernelConfig", RuntimeKernelConfig),
        ("PlacedLine", PlacedLine),
        ("BootScene", BootScene),
    ]

    failed = 0

    print("Wonderland Runtime Phase 1 Verify")
    print()

    for name, obj in checks:
        if obj is None:
            print(f"FAIL import {name}")
            failed += 1
        else:
            print(f"PASS import {name}")

    print()

    try:
        kernel = RuntimeKernel(
            context=RuntimeContext(interactive=False),
            config=RuntimeKernelConfig(max_frames=1, frame_delay=0),
        )
        scene = BootScene()
        scene.mount(kernel)
        lines = scene.render(kernel)
        frame = kernel.renderer.compose(kernel.screen.size(), lines)

        assert isinstance(lines, list)
        assert "WONDERLAND OS" in frame

        print("PASS smoke RuntimeKernel + BootScene")
    except Exception as exc:
        print(f"FAIL smoke RuntimeKernel + BootScene: {exc}")
        failed += 1

    print()
    if failed:
        print("Result: FAIL")
        return 1

    print("Result: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(verify())
