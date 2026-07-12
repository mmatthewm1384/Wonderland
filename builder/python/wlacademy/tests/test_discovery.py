from __future__ import annotations

import unittest

from wlacademy.discovery import collection_count


class DiscoveryTests(unittest.TestCase):
    def test_list_count(self) -> None:
        self.assertEqual(
            collection_count([1, 2, 3]),
            3,
        )

    def test_named_collection_count(self) -> None:
        self.assertEqual(
            collection_count(
                {
                    "schema_version": 1,
                    "lessons": [
                        {"id": "one"},
                        {"id": "two"},
                    ],
                }
            ),
            2,
        )

    def test_mapping_registry_count(self) -> None:
        self.assertEqual(
            collection_count(
                {
                    "schema_version": 1,
                    "registry": {
                        "one": {},
                        "two": {},
                    },
                }
            ),
            2,
        )


if __name__ == "__main__":
    unittest.main()
