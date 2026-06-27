from __future__ import annotations

import unittest
from pathlib import Path

from wl_controller.container.services import ServiceContainer


class ServiceContainerTests(unittest.TestCase):
    def test_config_is_singleton(self):
        root = Path.home() / "Wonderland"
        container = ServiceContainer(root)

        self.assertIs(container.config(), container.config())

    def test_runtime_uses_config_runtime(self):
        root = Path.home() / "Wonderland"
        container = ServiceContainer(root)

        self.assertEqual(container.runtime().lima_instance, container.config().runtime)

    def test_status_lists_created_services(self):
        root = Path.home() / "Wonderland"
        container = ServiceContainer(root)

        container.config()
        container.registry()

        status = container.status()

        self.assertIn("config", status["services"])
        self.assertIn("registry", status["services"])


if __name__ == "__main__":
    unittest.main()
