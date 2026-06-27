from __future__ import annotations

import unittest

from wl_controller.plugins.null import NullPluginManager


class PluginResilienceTests(unittest.TestCase):
    def test_null_plugin_manager_is_safe(self):
        manager = NullPluginManager("test unavailable")

        manager.discover()
        manager.before_cycle()
        manager.after_cycle({})
        manager.on_event({})

        status = manager.status()

        self.assertFalse(status["enabled"])
        self.assertEqual(status["count"], 0)
        self.assertIn("test unavailable", status["errors"])


if __name__ == "__main__":
    unittest.main()
