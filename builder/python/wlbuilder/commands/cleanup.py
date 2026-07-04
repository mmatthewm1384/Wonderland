from __future__ import annotations

from wlbuilder.commands_util import run_command
from wlbuilder.native_state import read_state
from wlbuilder.runtime_context import RuntimeContext


def run(context: RuntimeContext) -> int:
    builder = context.builder
    state = read_state(builder)

    mount = state.get("mount", {})
    mount_root = mount.get("mount_root")
    loop = mount.get("loop")

    if mount_root:
        run_command(["sudo", "umount", "-R", str(mount_root)], check=False)
        print(f"unmounted: {mount_root}")

    if loop:
        run_command(["sudo", "losetup", "-d", str(loop)], check=False)
        print(f"detached: {loop}")

    if not mount_root and not loop:
        print("cleanup: no native mount state found")

    return 0
