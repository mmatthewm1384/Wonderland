#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

cd "$ROOT"

STAMP="$(date +%Y%m%d-%H%M%S)"

cp builder/python/wlruntime/wlruntime/engine.py \
   builder/python/wlruntime/wlruntime/engine.py.before-v3.$STAMP


python3 <<'PY'
from pathlib import Path

path = Path(
    "builder/python/wlruntime/wlruntime/engine.py"
)

text = path.read_text()


start = text.index(
    "    def start(self, *, dry_run: bool = False)"
)

end = text.index(
    "    def verify(self) -> dict[str, Any]:",
    start,
)


replacement = r'''
    def start(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        with self.state_store.lock():
            return self._start_locked(
                dry_run=dry_run
            )


    def _start_locked(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return self.plan("start")

        state = self.state_store.read()

        if state["status"] == "running":
            return {
                "result": "PASS",
                "changed": False,
                "reason": "runtime already running",
                "state": state,
            }

        if state["status"] in {
            "starting",
            "stopping",
            "rolling-back",
        }:
            raise LifecycleExecutionError(
                f"runtime busy: {state['status']}"
            )

        state = self.state_store.default_state()

        state.update(
            {
                "status": "starting",
                "operation": "start",
                "operation_id": str(uuid.uuid4()),
                "registry_digest": self.registry.digest(),
            }
        )

        self.state_store.write(state)

        started = []

        for engine_id in self.registry.start_order():
            engine = self.registry.engine(engine_id)

            result = self._execute(
                engine,
                "start",
            )

            state["engine_results"][engine_id] = result

            if result["status"] in {"PASS", "SKIP"}:
                started.append(engine_id)
                state["started_engines"] = list(started)
                self.state_store.write(state)
                continue

            if not engine.required:
                self.state_store.write(state)
                continue

            state["status"] = "rolling-back"
            state["last_error"] = {
                "engine_id": engine_id,
                "action": "start",
                "message": result["error"],
                "occurred_at": utc_now(),
            }

            state["rollback"]["attempted"] = True

            self.state_store.write(state)

            rollback = self._rollback(started)

            completed = all(
                item["status"] in {"PASS", "SKIP"}
                for item in rollback
            )

            state["rollback"]["results"] = rollback
            state["rollback"]["completed"] = completed
            state["started_engines"] = []
            state["operation"] = None
            state["operation_id"] = None
            state["status"] = (
                "stopped"
                if completed
                else "failed"
            )

            self.state_store.write(state)

            raise LifecycleExecutionError(
                f"required engine {engine_id} failed; "
                f"rollback "
                f"{'completed' if completed else 'failed'}"
            )

        state["status"] = "running"
        state["operation"] = None
        state["operation_id"] = None

        self.state_store.write(state)

        return {
            "result": "PASS",
            "changed": True,
            "state": state,
        }


    def stop(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        with self.state_store.lock():
            return self._stop_locked(
                dry_run=dry_run
            )


    def _stop_locked(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return self.plan("stop")

        state = self.state_store.read()

        if state["status"] == "stopped":
            return {
                "result": "PASS",
                "changed": False,
                "reason": "runtime already stopped",
                "state": state,
            }

        state["status"] = "stopping"
        state["operation"] = "stop"
        state["operation_id"] = str(uuid.uuid4())

        self.state_store.write(state)

        failures = []

        for engine_id in self.registry.stop_order():
            engine = self.registry.engine(engine_id)

            result = self._execute(
                engine,
                "stop",
            )

            state["engine_results"][engine_id] = result

            if (
                result["status"] == "FAIL"
                and engine.required
            ):
                failures.append(engine_id)

            self.state_store.write(state)

        state["operation"] = None
        state["operation_id"] = None
        state["started_engines"] = []

        if failures:
            state["status"] = "failed"

            state["last_error"] = {
                "action": "stop",
                "engines": failures,
                "message": "required engines failed to stop",
                "occurred_at": utc_now(),
            }

            self.state_store.write(state)

            raise LifecycleExecutionError(
                "required engines failed to stop: "
                + ", ".join(failures)
            )

        state["status"] = "stopped"
        state["last_error"] = None

        self.state_store.write(state)

        return {
            "result": "PASS",
            "changed": True,
            "state": state,
        }


    def restart(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return {
                "result": "PASS",
                "action": "restart",
                "stop": self.plan("stop"),
                "start": self.plan("start"),
            }

        with self.state_store.lock():
            stop_result = self._stop_locked()
            start_result = self._start_locked()

            return {
                "result": "PASS",
                "action": "restart",
                "stop": stop_result,
                "start": start_result,
            }


    def sleep(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return self.plan("stop")

        with self.state_store.lock():
            result = self._stop_locked()

            state = self.state_store.read()

            state["lifecycle"] = {
                "last_transition": "sleep",
                "sleep_timestamp": utc_now(),
            }

            self.state_store.write(state)

            return {
                "result": "PASS",
                "action": "sleep",
                "stop": result,
                "state": state,
            }


    def wake(
        self,
        *,
        dry_run: bool = False,
    ) -> dict[str, Any]:
        if dry_run:
            return self.plan("start")

        with self.state_store.lock():
            result = self._start_locked()

            state = self.state_store.read()

            state["lifecycle"] = {
                "last_transition": "wake",
                "sleep_timestamp": None,
            }

            self.state_store.write(state)

            return {
                "result": "PASS",
                "action": "wake",
                "start": result,
                "state": state,
            }


'''

text = text[:start] + replacement + text[end:]

path.write_text(text)

print("Lifecycle Patch v3 applied.")
PY


python3 -m compileall builder/python/wlruntime/wlruntime


PYTHONPATH=builder/python/wlruntime \
python3 -m wlruntime.cli \
--root "$ROOT" \
self-test
