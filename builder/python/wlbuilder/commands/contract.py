from __future__ import annotations

from wlbuilder.runtime_context import RuntimeContext


REQUIRED_CONTEXT_FIELDS = [
    "repo_root",
    "builder_root",
    "config",
    "profile",
    "output_root",
    "raw_output",
    "qcow2_output",
    "vmware_output",
    "log_root",
    "manifest_root",
    "cache_root",
    "tmp_root",
]


def run(context: RuntimeContext) -> int:
    builder = context.builder
    failures: list[str] = []

    for field in REQUIRED_CONTEXT_FIELDS:
        if not hasattr(builder, field):
            failures.append(f"missing context field: {field}")

    for field in REQUIRED_CONTEXT_FIELDS:
        path = getattr(builder, field, None)
        if field.endswith("_root") or field.endswith("_output"):
            if path is not None and hasattr(path, "is_absolute") and not path.is_absolute():
                failures.append(f"{field} must be absolute: {path}")
            if path is not None and "builder/output" in str(path):
                failures.append(f"{field} must not use legacy builder/output: {path}")

    if failures:
        for failure in failures:
            print(f"FAIL contract: {failure}")
        return 1

    print("PASS Builder V2 internal API contract")
    print(f"output_root: {builder.output_root}")
    return 0
