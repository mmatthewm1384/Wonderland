from __future__ import annotations

import unittest

from wonderland import WonderlandClient


class SDKTests(unittest.TestCase):
    def test_client_ready(self):
        client = WonderlandClient()
        ready = client.ready()

        self.assertIn("ready", ready)

    def test_client_services(self):
        client = WonderlandClient()
        services = client.resolved_services()

        self.assertIsInstance(services, list)

    def test_openapi(self):
        client = WonderlandClient()
        spec = client.openapi()

        self.assertEqual(spec["info"]["title"], "Wonderland Platform API")


if __name__ == "__main__":
    unittest.main()
