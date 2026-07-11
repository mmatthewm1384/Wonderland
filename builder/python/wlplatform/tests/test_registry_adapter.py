from __future__ import annotations

import unittest

from wlplatform.registry_adapter import (
    PUBLIC_REQUIRED_COMMANDS,
    _extract_commands,
)


class RegistryAdapterTests(unittest.TestCase):
    def test_extracts_mapping_keys(self) -> None:
        commands = _extract_commands(
            {
                "runtime": object(),
                "architecture": object(),
            }
        )

        self.assertEqual(
            commands,
            {"runtime", "architecture"},
        )

    def test_extracts_named_sequence_entries(self) -> None:
        commands = _extract_commands(
            [
                {"name": "builder"},
                {"command": "governance"},
            ]
        )

        self.assertEqual(
            commands,
            {"builder", "governance"},
        )

    def test_required_public_contract(self) -> None:
        self.assertEqual(
            PUBLIC_REQUIRED_COMMANDS,
            {
                "architecture",
                "builder",
                "governance",
                "runtime",
            },
        )


if __name__ == "__main__":
    unittest.main()
