from __future__ import annotations

import unittest

from wlplatform.cli import normalize_argv


class CliTests(unittest.TestCase):
    def test_empty_defaults_to_verify(self) -> None:
        self.assertEqual(
            normalize_argv([]),
            ["verify"],
        )

    def test_forwarded_option_defaults_to_verify(self) -> None:
        self.assertEqual(
            normalize_argv(["--verbose"]),
            ["verify", "--verbose"],
        )

    def test_explicit_command_is_preserved(self) -> None:
        self.assertEqual(
            normalize_argv(["certify", "--json"]),
            ["certify", "--json"],
        )


if __name__ == "__main__":
    unittest.main()
