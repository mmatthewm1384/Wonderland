from __future__ import annotations

import unittest

from wlacademy.result import (
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

    def test_warning_is_nonfatal(self) -> None:
        self.assertEqual(
            aggregate(
                (
                    CheckResult(
                        "registry",
                        Status.WARN,
                        "missing",
                    ),
                )
            ),
            Status.WARN,
        )

    def test_skip_is_nonfatal(self) -> None:
        self.assertEqual(
            aggregate(
                (
                    CheckResult(
                        "manifest",
                        Status.SKIP,
                        "not applicable",
                    ),
                )
            ),
            Status.SKIP,
        )


if __name__ == "__main__":
    unittest.main()
