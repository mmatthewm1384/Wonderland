from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from dataclasses import asdict, dataclass, field
from pathlib import Path

from wlcli.core.ui import GREEN, RED, YELLOW, CYAN, PURPLE, DIM, RESET, BOLD, fail, ok, warn
from wlcli.core.state.history import append_history


@dataclass(frozen=True)
class Stage:
    id: str
    title: str
    command: list[str]
    depends_on: list[str] = field(default_factory=list)
    required: bool = True
    timeout: int = 60
    health: list[str] = field(default_factory=list)


@dataclass
class StageResult:
    id: str
    title: str
    state: str
    code: int
    duration: float
    log: str
    required: bool


class BootGraph:
    def __init__(self, root: Path, log_dir: Path, state_file: Path):
        self.root = root
        self.log_dir = log_dir
        self.state_file = state_file
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.state_file.parent.mkdir(parents=True, exist_ok=True)

    def start_stages(self) -> list[Stage]:
        return [
            Stage(
                "runtime",
                "Rootless Runtime",
                [self.bin("wl-rootless"), "start"],
                health=[self.bin("wl-rootless"), "status"],
            ),
            Stage(
                "services",
                "Core Services",
                [self.bin("wl-services"), "start"],
                ["runtime"],
                health=[self.bin("wl-services"), "status"],
            ),
            Stage(
                "apps",
                "Graphical Shell",
                [self.bin("wl-apps"), "start"],
                ["services"],
                required=False,
                health=[self.bin("wl-apps"), "status"],
            ),
            Stage(
                "verify",
                "Runtime Verification",
                [self.bin("wlcli"), "status"],
                ["services"],
                required=True,
            ),
        ]

    def stop_stages(self) -> list[Stage]:
        return [
            Stage("apps", "Graphical Shell", [self.bin("wl-apps"), "stop"], required=False),
            Stage("services", "Core Services", [self.bin("wl-services"), "stop"], ["apps"]),
            Stage("runtime", "Rootless Runtime", [self.bin("wl-rootless"), "stop"], ["services"]),
        ]

    def graph_json(self, stages: list[Stage]) -> str:
        ordered = self.resolve(stages)
        payload = {
            "graph": "START",
            "stage_count": len(ordered),
            "stages": [
                {
                    "id": stage.id,
                    "title": stage.title,
                    "command": stage.command,
                    "depends_on": stage.depends_on,
                    "required": stage.required,
                    "timeout": stage.timeout,
                    "health": stage.health,
                }
                for stage in ordered
            ],
        }
        return json.dumps(payload, indent=2)

    def bin(self, name: str) -> str:
        return str(self.root / "bin" / name)

    def validate(self, stages: list[Stage]) -> tuple[bool, list[str]]:
        errors: list[str] = []
        warnings: list[str] = []

        seen: set[str] = set()
        for stage in stages:
            if stage.id in seen:
                errors.append(f"duplicate stage id: {stage.id}")
            seen.add(stage.id)

            if not stage.id:
                errors.append("stage id cannot be empty")

            if not stage.title:
                errors.append(f"stage {stage.id} title cannot be empty")

            if stage.timeout <= 0:
                errors.append(f"stage {stage.id} timeout must be positive")

            if not stage.command:
                errors.append(f"stage {stage.id} command cannot be empty")
            else:
                cmd = Path(stage.command[0])
                if not cmd.exists():
                    errors.append(f"stage {stage.id} command missing: {cmd}")
                elif not cmd.is_file():
                    errors.append(f"stage {stage.id} command is not a file: {cmd}")
                elif not os.access(cmd, os.X_OK):
                    errors.append(f"stage {stage.id} command not executable: {cmd}")

            if stage.health:
                health_cmd = Path(stage.health[0])
                if not health_cmd.exists():
                    warnings.append(f"stage {stage.id} health command missing: {health_cmd}")
                elif not os.access(health_cmd, os.X_OK):
                    warnings.append(f"stage {stage.id} health command not executable: {health_cmd}")

            for dep in stage.depends_on:
                if dep not in {s.id for s in stages}:
                    errors.append(f"stage {stage.id} depends on missing stage: {dep}")

        try:
            self.resolve(stages)
        except Exception as e:
            errors.append(str(e))

        return len(errors) == 0, errors + warnings

    def resolve(self, stages: list[Stage]) -> list[Stage]:
        by_id = {s.id: s for s in stages}
        resolved: list[Stage] = []
        visiting: set[str] = set()
        visited: set[str] = set()

        def visit(stage: Stage) -> None:
            if stage.id in visited:
                return
            if stage.id in visiting:
                raise RuntimeError(f"cycle detected at stage: {stage.id}")

            visiting.add(stage.id)

            for dep in stage.depends_on:
                if dep not in by_id:
                    raise RuntimeError(f"stage {stage.id} depends on missing stage: {dep}")
                visit(by_id[dep])

            visiting.remove(stage.id)
            visited.add(stage.id)
            resolved.append(stage)

        for stage in stages:
            visit(stage)

        return resolved

    def run(self, name: str, stages: list[Stage]) -> int:
        ordered = self.resolve(stages)
        results: list[StageResult] = []

        print(f"{PURPLE}╭────────────────────────────────────╮{RESET}")
        print(f"{PURPLE}│{RESET} {CYAN}{BOLD}Wonderland Boot Graph{RESET} {DIM}{name}{RESET}      {PURPLE}│{RESET}")
        print(f"{PURPLE}╰────────────────────────────────────╯{RESET}\n")

        total_start = time.time()

        for index, stage in enumerate(ordered, start=1):
            progress = int((index - 1) / max(len(ordered), 1) * 100)
            self.print_progress(progress, stage.title)

            result = self.run_stage(stage)
            results.append(result)
            self.write_state(name, results)

            if result.state == "PASS":
                print(f"{GREEN}PASS{RESET} {stage.title} {DIM}{result.duration:.2f}s{RESET}")
                continue

            if stage.required:
                print(f"{RED}FAIL{RESET} {stage.title} {DIM}{result.duration:.2f}s{RESET}")
                warn(f"log: {result.log}")
                self.tail_log(Path(result.log), 60)
                total_duration = time.time() - total_start
                self.summary(name, results, total_duration)
                append_history(
                    self.root,
                    command=name.lower(),
                    result="FAIL",
                    duration=total_duration,
                    graph=name,
                    stage_results=results,
                    runtime_instance=os.environ.get("WL_RUNTIME_INSTANCE", "wonderland-rootless"),
                )
                print("RESULT FAIL")
                return result.code or 1

            print(f"{YELLOW}WARN{RESET} {stage.title} optional failed {DIM}{result.duration:.2f}s{RESET}")
            warn(f"log: {result.log}")

        self.print_progress(100, "READY")
        total_duration = time.time() - total_start
        self.summary(name, results, total_duration)
        append_history(
            self.root,
            command=name.lower(),
            result="PASS",
            duration=total_duration,
            graph=name,
            stage_results=results,
            runtime_instance=os.environ.get("WL_RUNTIME_INSTANCE", "wonderland-rootless"),
        )
        print("RESULT PASS")
        return 0

    def run_stage(self, stage: Stage) -> StageResult:
        safe = "".join(c if c.isalnum() else "_" for c in stage.id)
        log = self.log_dir / f"wl-stage-{safe}.log"

        env = os.environ.copy()
        env.setdefault("WL_HOME", str(self.root))
        env.setdefault("WL_RUNTIME_INSTANCE", "wonderland-rootless")
        env.setdefault("LIMA_INSTANCE", env["WL_RUNTIME_INSTANCE"])

        started = time.time()

        with log.open("w") as f:
            try:
                proc = subprocess.run(
                    stage.command,
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    env=env,
                    timeout=stage.timeout,
                    check=False,
                )
                code = proc.returncode
            except subprocess.TimeoutExpired:
                f.write(f"\nTIMEOUT after {stage.timeout}s\n")
                code = 124
            except FileNotFoundError as e:
                f.write(f"\nMISSING command: {e}\n")
                code = 127

        duration = time.time() - started
        if code == 0 and stage.health:
            health_log = self.log_dir / f"wl-stage-{safe}-health.log"
            with health_log.open("w") as f:
                try:
                    health_proc = subprocess.run(
                        stage.health,
                        stdout=f,
                        stderr=subprocess.STDOUT,
                        env=env,
                        timeout=min(stage.timeout, 30),
                        check=False,
                    )
                    if health_proc.returncode != 0:
                        code = health_proc.returncode
                        log = health_log
                except subprocess.TimeoutExpired:
                    f.write("\nHEALTH TIMEOUT\n")
                    code = 124
                    log = health_log
                except FileNotFoundError as e:
                    f.write(f"\nMISSING health command: {e}\n")
                    code = 127
                    log = health_log

        state = "PASS" if code == 0 else ("WARN" if not stage.required else "FAIL")

        return StageResult(
            id=stage.id,
            title=stage.title,
            state=state,
            code=code,
            duration=duration,
            log=str(log),
            required=stage.required,
        )

    def write_state(self, name: str, results: list[StageResult]) -> None:
        payload = {
            "graph": name,
            "updated_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
            "results": [asdict(r) for r in results],
        }
        self.state_file.write_text(json.dumps(payload, indent=2) + "\n")

    def summary(self, name: str, results: list[StageResult], total: float) -> None:
        print()
        print(f"{BOLD}{name} Summary{RESET}")
        for r in results:
            color = GREEN if r.state == "PASS" else YELLOW if r.state == "WARN" else RED
            print(f"{color}{r.state:<4}{RESET} {r.title:<24} {DIM}{r.duration:.2f}s{RESET}")
        print(f"\nBoot Time ............. {total:.2f}s")

    def print_progress(self, percent: int, label: str) -> None:
        width = 28
        filled = int(width * percent / 100)
        bar = "█" * filled + "░" * (width - filled)
        print(f"{CYAN}{bar}{RESET} {percent:>3}% {DIM}{label}{RESET}")

    def tail_log(self, path: Path, lines: int) -> None:
        try:
            content = path.read_text(errors="replace").splitlines()[-lines:]
            if content:
                print()
                print("\n".join(content))
                print()
        except Exception:
            pass
