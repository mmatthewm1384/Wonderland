from __future__ import annotations

import unittest

from wlmirror.result import (
    CheckResult,
    Status,
    aggregate,
)


class ResultTests(unittest.TestCase):
    def test_failure_dominates(self) -> None:
        self.assertEqual(
            aggregate(
                (
                    CheckResult("a", Status.PASS, "ok"),
                    CheckResult("b", Status.FAIL, "bad"),
                )
            ),
            Status.FAIL,
        )

    def test_idle_is_nonfatal(self) -> None:
        self.assertEqual(
            aggregate(
                (
                    CheckResult(
                        "destination",
                        Status.IDLE,
                        "unavailable",
                    ),
                )
            ),
            Status.IDLE,
        )

    def test_warning_is_nonfatal(self) -> None:
        self.assertEqual(
            aggregate(
                (
                    CheckResult(
                        "authority",
                        Status.WARN,
                        "implicit",
                    ),
                )
            ),
            Status.WARN,
        )


if __name__ == "__main__":
    unittest.main()
