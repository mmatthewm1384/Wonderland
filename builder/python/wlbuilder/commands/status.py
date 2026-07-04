from __future__ import annotations

import importlib
import sys
from pathlib import Path

from wlbuilder.context import create_context
from wlbuilder.runtime_context import RuntimeContext
from wlbuilder.stages import default_pipeline


def run(context: RuntimeContext) -> int:
    repo_root = context.repo_root
    runtime = Path(__file__).resolve().parents[1] / "runtime.py"
    legacy = repo_root / "build" / "__main__.py"

    print("wlbuilder runtime: active")
    print(f"repo_root: {repo_root}")
    print(f"runtime: {runtime}")
    print("execution_path: builder/python/wlbuilder/runtime.py")
    print("legacy_bridge: build.__main__")
    print(f"legacy_bridge_file: {legacy}")
    print(f"legacy_bridge_exists: {str(legacy.exists()).lower()}")

    try:
        if str(repo_root) not in sys.path:
            sys.path.insert(0, str(repo_root))
        importlib.import_module("build.__main__")
        print("legacy_bridge_import: pass")
    except Exception as exc:
        print(f"legacy_bridge_import: fail: {exc}")

    try:
        builder_context = create_context(repo_root)
        print("config: pass")
        print(f"config_file: {builder_context.config.path}")
        print(f"default_profile: {builder_context.config.default_profile}")
        print(f"profile: {builder_context.profile}")
        print(f"output_root: {builder_context.output_root}")
        print(f"raw_output: {builder_context.raw_output}")
        print(f"qcow2_output: {builder_context.qcow2_output}")
        print(f"vmware_output: {builder_context.vmware_output}")
        print(f"log_root: {builder_context.log_root}")
        print(f"manifest_root: {builder_context.manifest_root}")

        print("pipeline:")
        for stage in default_pipeline():
            implementation = "native" if getattr(stage, "implemented", False) else "pending"
            print(f"  - {stage.name} ({implementation})")

        from wlbuilder.native_state import read_state, state_path

        state = read_state(builder_context)
        print(f"native_state_file: {state_path(builder_context)}")
        print("native_state:")
        if state:
            for name in sorted(state):
                print(f"  - {name}")
        else:
            print("  - none")
    except Exception as exc:
        print(f"config: fail: {exc}")

    return 0
