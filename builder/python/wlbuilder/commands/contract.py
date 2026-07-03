from __future__ import annotations

from pathlib import Path

from wlbuilder.context import create_context


def run(repo_root: Path) -> int:
    context = create_context(repo_root)

    failures: list[str] = []

    if not context.output_root.is_absolute():
        failures.append(f"output_root is not absolute: {context.output_root}")

    try:
        context.output_root.relative_to(context.repo_root)
        failures.append(f"output_root must not be inside repo: {context.output_root}")
    except ValueError:
        pass

    required_paths = [
        context.raw_output,
        context.qcow2_output,
        context.vmware_output,
        context.log_root,
        context.manifest_root,
        context.cache_root,
        context.tmp_root,
    ]

    for path in required_paths:
        if not path.is_absolute():
            failures.append(f"path is not absolute: {path}")

    legacy = repo_root / "builder" / "output"
    for path in required_paths:
        try:
            path.relative_to(legacy)
            failures.append(f"path uses legacy builder/output: {path}")
        except ValueError:
            pass

    if failures:
        for failure in failures:
            print(f"FAIL contract: {failure}")
        return 1

    print("PASS Builder V2 contract")
    print(f"output_root: {context.output_root}")
    return 0
