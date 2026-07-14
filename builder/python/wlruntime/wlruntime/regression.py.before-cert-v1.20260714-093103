"""Isolated regression suite for Wonderland Runtime Engine."""

from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from typing import Any

from .engine import RuntimeEngine
from .errors import (
    LifecycleExecutionError,
    RegistryValidationError,
)
from .registry import EngineRegistry
from .state import RuntimeStateStore


def write_registry(
    root: Path,
    engines: dict[str, Any],
) -> Path:
    path = root / "registry.json"

    path.write_text(
        json.dumps(
            {
                "schema_version": 1,
                "engines": engines,
            },
            indent=2,
            sort_keys=True,
        )
        + "\n",
        encoding="utf-8",
    )

    return path


def noop_engine(
    *,
    dependencies: list[str] | None = None,
    required: bool = True,
) -> dict[str, Any]:
    return {
        "description": "Regression test engine",
        "dependencies": dependencies or [],
        "required": required,
        "commands": {
            "start": {
                "argv": ["/usr/bin/true"],
                "timeout_seconds": 10,
            },
            "stop": {
                "argv": ["/usr/bin/true"],
                "timeout_seconds": 10,
            },
            "verify": {
                "argv": ["/usr/bin/true"],
                "timeout_seconds": 10,
            },
        },
    }


class RegistryContractTests(unittest.TestCase):
    def test_schema_version_is_one(self) -> None:
        self.assertEqual(
            EngineRegistry.SCHEMA_VERSION,
            1,
        )

    def test_deterministic_topological_order(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            registry = EngineRegistry(
                write_registry(
                    root,
                    {
                        "gamma": noop_engine(
                            dependencies=["alpha", "beta"]
                        ),
                        "beta": noop_engine(
                            dependencies=["alpha"]
                        ),
                        "alpha": noop_engine(),
                    },
                )
            )

            self.assertEqual(
                registry.start_order(),
                ("alpha", "beta", "gamma"),
            )
            self.assertEqual(
                registry.stop_order(),
                ("gamma", "beta", "alpha"),
            )

    def test_cycle_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = write_registry(
                root,
                {
                    "alpha": noop_engine(
                        dependencies=["beta"]
                    ),
                    "beta": noop_engine(
                        dependencies=["alpha"]
                    ),
                },
            )

            with self.assertRaises(
                RegistryValidationError
            ):
                EngineRegistry(path)

    def test_unresolved_dependency_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            path = write_registry(
                root,
                {
                    "alpha": noop_engine(
                        dependencies=["missing"]
                    )
                },
            )

            with self.assertRaises(
                RegistryValidationError
            ):
                EngineRegistry(path)


class PersistentStateContractTests(unittest.TestCase):
    def test_state_schema_version_is_one(self) -> None:
        self.assertEqual(
            RuntimeStateStore.SCHEMA_VERSION,
            1,
        )

    def test_atomic_state_round_trip(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            store = RuntimeStateStore(
                root / "state.json"
            )

            state = store.default_state()
            state["status"] = "running"
            state["started_engines"] = ["alpha"]

            store.write(state)
            loaded = store.read()

            self.assertEqual(
                loaded["status"],
                "running",
            )
            self.assertEqual(
                loaded["started_engines"],
                ["alpha"],
            )
            self.assertEqual(
                loaded["schema_version"],
                1,
            )


class LifecycleContractTests(unittest.TestCase):
    def build_engine(
        self,
        root: Path,
        engines: dict[str, Any],
    ) -> tuple[
        EngineRegistry,
        RuntimeStateStore,
        RuntimeEngine,
    ]:
        registry = EngineRegistry(
            write_registry(root, engines)
        )
        store = RuntimeStateStore(
            root / "state.json"
        )
        engine = RuntimeEngine(
            root=root,
            registry=registry,
            state_store=store,
        )

        return registry, store, engine

    def test_start_and_stop_are_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            _, store, engine = self.build_engine(
                root,
                {
                    "alpha": noop_engine(),
                    "beta": noop_engine(
                        dependencies=["alpha"]
                    ),
                },
            )

            first_start = engine.start()
            second_start = engine.start()
            first_stop = engine.stop()
            second_stop = engine.stop()

            self.assertTrue(first_start["changed"])
            self.assertFalse(second_start["changed"])
            self.assertTrue(first_stop["changed"])
            self.assertFalse(second_stop["changed"])

            state = store.read()

            self.assertEqual(
                state["status"],
                "stopped",
            )
            self.assertEqual(
                state["started_engines"],
                [],
            )

    def test_required_failure_rolls_back(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            alpha = noop_engine()
            failure = noop_engine(
                dependencies=["alpha"]
            )
            failure["commands"]["start"] = {
                "argv": ["/usr/bin/false"],
                "timeout_seconds": 10,
            }

            _, store, engine = self.build_engine(
                root,
                {
                    "alpha": alpha,
                    "failure": failure,
                },
            )

            with self.assertRaises(
                LifecycleExecutionError
            ):
                engine.start()

            state = store.read()

            self.assertEqual(
                state["status"],
                "stopped",
            )
            self.assertEqual(
                state["started_engines"],
                [],
            )
            self.assertIsNone(
                state["operation"]
            )
            self.assertIsNone(
                state["operation_id"]
            )
            self.assertTrue(
                state["rollback"]["attempted"]
            )
            self.assertTrue(
                state["rollback"]["completed"]
            )
            self.assertEqual(
                state["last_error"]["engine_id"],
                "failure",
            )

            rollback_results = (
                state["rollback"]["results"]
            )

            self.assertEqual(
                len(rollback_results),
                1,
            )
            self.assertEqual(
                rollback_results[0]["engine_id"],
                "alpha",
            )
            self.assertEqual(
                rollback_results[0]["status"],
                "PASS",
            )

    def test_structural_verify_does_not_execute_health(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)

            unhealthy = noop_engine()
            unhealthy["commands"]["verify"] = {
                "argv": ["/usr/bin/false"],
                "timeout_seconds": 10,
            }

            _, _, engine = self.build_engine(
                root,
                {"alpha": unhealthy},
            )

            structural = engine.verify()
            operational = engine.health()

            self.assertEqual(
                structural["result"],
                "PASS",
            )
            self.assertEqual(
                structural["mode"],
                "structural",
            )
            self.assertEqual(
                operational["result"],
                "FAIL",
            )
            self.assertEqual(
                operational["mode"],
                "operational",
            )


def run_regression_suite(
    *,
    verbosity: int = 2,
) -> dict[str, Any]:
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    for case in (
        RegistryContractTests,
        PersistentStateContractTests,
        LifecycleContractTests,
    ):
        suite.addTests(
            loader.loadTestsFromTestCase(case)
        )

    runner = unittest.TextTestRunner(
        verbosity=verbosity,
    )
    result = runner.run(suite)

    return {
        "result": (
            "PASS"
            if result.wasSuccessful()
            else "FAIL"
        ),
        "tests_run": result.testsRun,
        "failures": len(result.failures),
        "errors": len(result.errors),
        "skipped": len(result.skipped),
        "schema_contracts": {
            "registry": EngineRegistry.SCHEMA_VERSION,
            "state": RuntimeStateStore.SCHEMA_VERSION,
        },
    }
