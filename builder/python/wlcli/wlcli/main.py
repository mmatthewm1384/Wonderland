from __future__ import annotations

import argparse
import os
import subprocess
import sys
from wlcli.namespaces import normalize_command
from wlcli.core.architecture import verify_beta_architecture
from wlcli.core.commands.registry import get_command
from wlcli.runtime.context import RuntimeContext
from pathlib import Path

from wlcli.ui import logo, ok, warn, fail, run_step
from wlcli.graph import BootGraph
from wlcli.history_cmd import history, history_json
from wlcli.metrics_cmd import metrics, metrics_json
from wlcli.doctor import graph_doctor
from wlcli.registry import command_map, print_commands, print_commands_json, print_help
from wlcli.renderer import render_report
from wlcli.report import build_boot_report, build_graph_current, graph_clean, graph_logs, graph_open_log, graph_state
import shutil


def wl_root() -> Path:
    return Path(os.environ.get("WL_HOME", Path.cwd())).resolve()


def env() -> dict[str, str]:
    e = os.environ.copy()
    e.setdefault("WL_HOME", str(wl_root()))
    e.setdefault("WL_RUNTIME_INSTANCE", "wonderland-rootless")
    e.setdefault("LIMA_INSTANCE", e["WL_RUNTIME_INSTANCE"])
    return e


def executable(path: Path) -> bool:
    return path.exists() and os.access(path, os.X_OK)


def run_pipeline(name: str, steps: list[tuple[str, list[str]]]) -> int:
    root = wl_root()
    log_dir = Path(os.environ.get("WL_LOG_DIR", "/tmp"))

    logo()
    print(f"{name}\n")

    total = 0.0

    for step_name, command in steps:
        result = run_step(step_name, command, log_dir)
        total += result.duration
        if result.code != 0:
            print()
            fail(f"{name} failed at: {step_name}")
            print("RESULT FAIL")
            return result.code

    print()
    ok(f"{name} complete in {total:.2f}s")
    print("RESULT PASS")
    return 0


def graph_engine() -> BootGraph:
    root = wl_root()
    return BootGraph(
        root=root,
        log_dir=Path(os.environ.get("WL_LOG_DIR", "/tmp")),
        state_file=root / "vault/08-Operations/state/wl-boot-graph.json",
    )


def start() -> int:
    graph = graph_engine()
    return graph.run("START", graph.start_stages())


def stop() -> int:
    graph = graph_engine()
    return graph.run("STOP", graph.stop_stages())


def status() -> int:
    root = wl_root()
    logo()

    for cmd in ["wl-rootless", "wl-services"]:
        path = root / "bin" / cmd
        if executable(path):
            ok(f"{cmd} available")
        else:
            warn(f"{cmd} missing")

    subprocess.run([str(root / "bin/wl-rootless"), "status"], env=env(), check=False)
    subprocess.run([str(root / "bin/wl-services"), "status"], env=env(), check=False)
    return 0


def doctor() -> int:
    root = wl_root()
    logo()

    required = [
        root / "bin/wl",
        root / "bin/wl-rootless",
        root / "bin/wl-services",
        root / "bin/nerdctl",
    ]

    failed = False
    for path in required:
        if executable(path):
            ok(f"{path.relative_to(root)} executable")
        else:
            fail(f"{path.relative_to(root)} missing or not executable")
            failed = True

    if failed:
        print("RESULT FAIL")
        return 1

    print("RESULT PASS")
    return 0


def dispatch_registered(command: str, args: list[str]) -> int:
    root = wl_root()
    registry = command_map(root)

    entry = registry.get(command)
    if entry is None or entry.target is None:
        fail(f"unknown command: {command}")
        print()
        print_help(root)
        return 1

    target = root / "bin" / entry.target
    if not executable(target):
        fail(f"registered target missing or not executable: {entry.target}")
        return 1

    return subprocess.run([str(target), *args], env=env(), check=False).returncode



def self_test() -> int:
    root = wl_root()
    failed = False

    logo()

    wl = root / "bin/wl"
    wlcli = root / "bin/wlcli"

    checks = [
        ("bin/wl executable", wl.exists() and os.access(wl, os.X_OK)),
        ("bin/wlcli executable", wlcli.exists() and os.access(wlcli, os.X_OK)),
        ("Boot Graph module", (root / "builder/python/wlcli/wlcli/graph.py").exists()),
        ("Registry module", (root / "builder/python/wlcli/wlcli/registry.py").exists()),
        ("Report module", (root / "builder/python/wlcli/wlcli/report.py").exists()),
    ]

    text = wl.read_text(errors="replace") if wl.exists() else ""

    has_early_case = "case \"$cmd\" in" in text
    has_wlcli_exec = 'exec "$WL_ROOT/bin/wlcli" "$cmd" "$@"' in text

    lifecycle_commands = [
        "runtime", "start", "stop", "status", "doctor",
        "graph", "graph-json", "graph-validate", "graph-doctor", "graph-current", "graph-current-json", "graph-state", "graph-logs", "graph-open-log", "graph-clean", "boot-report", "boot-report-json",
        "commands", "commands-json", "self-test", "help",
    ]

    routed = has_early_case and has_wlcli_exec and all(cmd in text for cmd in lifecycle_commands)

    checks.append(("wl lifecycle routed to wlcli", routed))
    checks.append(("legacy lifecycle bypass guarded", has_wlcli_exec))

    for name, passed in checks:
        if passed:
            ok(name)
        else:
            fail(name)
            failed = True

    if failed:
        print("RESULT FAIL")
        return 1

    print("RESULT PASS")
    return 0

def main() -> int:
    parser = argparse.ArgumentParser(prog="wlcli", add_help=False)
    parser.add_argument("command", nargs="?", default="help")
    parser.add_argument("args", nargs=argparse.REMAINDER)
    ns = parser.parse_args()

    os.environ.update(env())

    command, args = normalize_command(ns.command, ns.args)

    object_handler = get_command(command.replace("runtime-", "runtime."))
    if object_handler is not None:
        return render_report(object_handler.run(RuntimeContext.from_env(), args))

    if command in ("-h", "--help", "help"):
        print_help(wl_root())
        return 0
    if command == "commands":
        print_commands(wl_root())
        return 0
    if command == "commands-json":
        print_commands_json(wl_root())
        return 0
    if command == "history":
        return history(wl_root(), args)
    if command == "history-json":
        return history_json(wl_root(), args)
    if command == "runtime-beta":
        return render_report(verify_beta_architecture(wl_root()))
    if command == "metrics":
        return metrics(wl_root())
    if command == "metrics-json":
        return metrics_json(wl_root())
    if command == "boot-report":
        return render_report(build_boot_report(wl_root()))
    if command == "boot-report-json":
        print(build_boot_report(wl_root()).to_json())
        return 0
    if command == "graph-current":
        return render_report(build_graph_current(wl_root()))
    if command == "graph-current-json":
        print(build_graph_current(wl_root()).to_json())
        return 0
    if command == "graph-state":
        return graph_state(wl_root())
    if command == "graph-logs":
        return graph_logs(Path(os.environ.get("WL_LOG_DIR", "/tmp")))
    if command == "graph-open-log":
        stage = args[0] if args else None
        return graph_open_log(Path(os.environ.get("WL_LOG_DIR", "/tmp")), stage)
    if command == "graph-clean":
        return graph_clean(wl_root(), Path(os.environ.get("WL_LOG_DIR", "/tmp")))
    if command == "self-test":
        return self_test()
    if command == "start":
        return start()
    if command == "stop":
        return stop()
    if command == "status":
        return status()
    if command == "doctor":
        return doctor()
    if command == "graph":
        graph = graph_engine()
        stages = graph.resolve(graph.start_stages())
        logo()
        print("Wonderland START graph\n")
        for stage in stages:
            deps = ", ".join(stage.depends_on) if stage.depends_on else "-"
            required = "required" if stage.required else "optional"
            print(f"{stage.id:<12} {stage.title:<24} deps={deps:<16} {required}")
        return 0
    if command == "graph-json":
        graph = graph_engine()
        print(graph.graph_json(graph.start_stages()))
        return 0
    if command == "graph-validate":
        graph = graph_engine()
        valid, messages = graph.validate(graph.start_stages())
        logo()
        print("Wonderland Boot Graph Validation\n")
        for message in messages:
            if "health" in message:
                warn(message)
            else:
                fail(message)
        if valid:
            ok("boot graph valid")
            print("RESULT PASS")
            return 0
        print("RESULT FAIL")
        return 1
    if command == "graph-doctor":
        return graph_doctor(wl_root(), Path(os.environ.get("WL_LOG_DIR", "/tmp")))

    return dispatch_registered(command, args)


if __name__ == "__main__":
    raise SystemExit(main())
