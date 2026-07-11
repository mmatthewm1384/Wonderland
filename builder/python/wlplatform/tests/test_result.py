from __future__ import annotations

import unittest

from wlplatform.result import (
    CheckResult,
    Status,
    aggregate_status,
)


class ResultTests(unittest.TestCase):
    def test_fail_dominates(self) -> None:
        checks = (
            CheckResult("a", Status.PASS, "ok"),
            CheckResult("b", Status.FAIL, "bad"),
        )

        self.assertEqual(
            aggregate_status(checks),
            Status.FAIL,
        )

    def test_warn_is_successful_exit_state(self) -> None:
        checks = (
            CheckResult("a", Status.PASS, "ok"),
            CheckResult("b", Status.WARN, "warning"),
        )

        self.assertEqual(
            aggregate_status(checks),
            Status.WARN,
        )

    def test_idle_is_distinct(self) -> None:
        checks = (
            CheckResult("runtime", Status.IDLE, "stopped"),
        )

        self.assertEqual(
            aggregate_status(checks),
            Status.IDLE,
        )


if __name__ == "__main__":
    unittest.main()
