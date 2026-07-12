from __future__ import annotations

import unittest

from wlacademy.cli import normalize


class CliTests(unittest.TestCase):
    def test_empty_defaults_to_status(self) -> None:
        self.assertEqual(
            normalize([]),
            ["status"],
        )

    def test_json_defaults_to_verify(self) -> None:
        self.assertEqual(
            normalize(["--json"]),
            ["verify", "--json"],
        )

    def test_operational_command_preserved(self) -> None:
        self.assertEqual(
            normalize(["lesson", "show", "intro"]),
            ["lesson", "show", "intro"],
        )


if __name__ == "__main__":
    unittest.main()
