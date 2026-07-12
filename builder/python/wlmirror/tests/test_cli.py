from __future__ import annotations

import unittest

from wlmirror.cli import normalize


class CliTests(unittest.TestCase):
    def test_empty_defaults_to_status(self) -> None:
        self.assertEqual(
            normalize([]),
            ["status"],
        )

    def test_leading_json_defaults_to_verify(self) -> None:
        self.assertEqual(
            normalize(["--json"]),
            ["verify", "--json"],
        )

    def test_explicit_snapshot_preserved(self) -> None:
        self.assertEqual(
            normalize(["snapshot", "--full"]),
            ["snapshot", "--full"],
        )


if __name__ == "__main__":
    unittest.main()
