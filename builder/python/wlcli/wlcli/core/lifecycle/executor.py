from __future__ import annotations

import os
import subprocess
import time
from dataclasses import asdict, dataclass
from pathlib import Path

from wlcli.core.events import EventBus, EventPublisher, default_subscribers
from wlcli.core.lifecycle.graphs import LifecycleGraph, LifecycleStage
from wlcli.core.runtime.context import RuntimeContext
from wlcli.output import CommandResult, ResultLine


@dataclass(frozen=True)
class LifecycleStageResult:
    id: str
    title: str
    state: str
    code: int
    duration: float
    log: str
    required: bool


class LifecycleExecutor:
    def __init__(self, context: RuntimeContext):
        self.context = context
        self.context.log_dir.mkdir(parents=True, exist_ok=True)

    def execute(self, graph: LifecycleGraph) -> CommandResult:
        ordered = self._resolve(graph.stages)

        event_bus = EventBus(self.context)
        for subscriber in default_subscribers():
            event_bus.register(subscriber)

        publisher = EventPublisher(event_bus, source="lifecycle")
        publisher.graph_started(graph.name, len(ordered))

        started = time.time()
        results: list[LifecycleStageResult] = []

        for stage in ordered:
            publisher.stage_started(graph.name, stage.id, stage.title)
            result = self._run_stage(stage)
            results.append(result)

            publisher.stage_completed(
                graph.name,
                stage_id=stage.id,
                title=stage.title,
                state=result.state,
                code=result.code,
                duration=result.duration,
                log=result.log,
            )

            if result.state == "FAIL" and stage.required:
                duration = time.time() - started
                publisher.graph_failed(graph.name, duration)
                return self._result(graph, results, duration, failed=True)

        duration = time.time() - started
        publisher.graph_completed(graph.name, duration)
        return self._result(graph, results, duration, failed=False)

    def _run_stage(self, stage: LifecycleStage) -> LifecycleStageResult:
        safe = "".join(c if c.isalnum() else "_" for c in f"{stage.id}-{stage.title}").strip("_")
        log = self.context.log_dir / f"wl-lifecycle-{safe}.log"
        started = time.time()

        with log.open("w") as f:
            try:
                proc = subprocess.run(
                    stage.command,
                    stdout=f,
                    stderr=subprocess.STDOUT,
                    env=self.context.env(),
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

        state = "PASS" if code == 0 else "WARN" if not stage.required else "FAIL"

        if state == "PASS" and stage.health:
            health_log = self.context.log_dir / f"wl-lifecycle-{safe}-health.log"
            with health_log.open("w") as f:
                try:
                    health_proc = subprocess.run(
                        stage.health,
                        stdout=f,
                        stderr=subprocess.STDOUT,
                        env=self.context.env(),
                        timeout=min(stage.timeout, 30),
                        check=False,
                    )
                    if health_proc.returncode != 0:
                        code = health_proc.returncode
                        log = health_log
                        state = "WARN" if not stage.required else "FAIL"
                except subprocess.TimeoutExpired:
                    f.write("\nHEALTH TIMEOUT\n")
                    code = 124
                    log = health_log
                    state = "WARN" if not stage.required else "FAIL"
                except FileNotFoundError as e:
                    f.write(f"\nMISSING health command: {e}\n")
                    code = 127
                    log = health_log
                    state = "WARN" if not stage.required else "FAIL"

        return LifecycleStageResult(
            id=stage.id,
            title=stage.title,
            state=state,
            code=code,
            duration=time.time() - started,
            log=str(log),
            required=stage.required,
        )

    def _resolve(self, stages: list[LifecycleStage]) -> list[LifecycleStage]:
        by_id = {stage.id: stage for stage in stages}
        ordered: list[LifecycleStage] = []
        visiting: set[str] = set()
        visited: set[str] = set()

        def visit(stage: LifecycleStage) -> None:
            if stage.id in visited:
                return
            if stage.id in visiting:
                raise ValueError(f"cycle detected at stage: {stage.id}")

            visiting.add(stage.id)

            for dep in stage.depends_on:
                if dep not in by_id:
                    raise ValueError(f"stage {stage.id} depends on missing stage: {dep}")
                visit(by_id[dep])

            visiting.remove(stage.id)
            visited.add(stage.id)
            ordered.append(stage)

        for stage in stages:
            visit(stage)

        return ordered

    def _result(
        self,
        graph: LifecycleGraph,
        results: list[LifecycleStageResult],
        duration: float,
        *,
        failed: bool,
    ) -> CommandResult:
        lines = [
            ResultLine(
                state=item.state,
                title=item.title,
                detail=item.log,
                duration=item.duration,
            )
            for item in results
        ]

        state = "FAIL" if failed else "WARN" if any(r.state == "WARN" for r in results) else "PASS"

        return CommandResult(
            title=f"Wonderland Lifecycle {graph.name}",
            state=state,
            message="lifecycle failed" if state == "FAIL" else "lifecycle completed",
            lines=lines,
            metadata={"Graph": graph.name, "Duration": f"{duration:.2f}s"},
            payload={
                "graph": graph.name,
                "duration": duration,
                "results": [asdict(item) for item in results],
            },
        )
