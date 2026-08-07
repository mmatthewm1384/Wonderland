from pathlib import Path
import json


class RuntimeTargetRegistry:

    def _certification_status(self, target_id):
        import json

        cert = (
            self.root
            / "vault"
            / "08-Operations"
            / "certifications"
            / "runtime"
            / "runtime-certification-adapter-wiring-v1.json"
        )

        if not cert.exists():
            return False

        try:
            data = json.loads(cert.read_text())
            return (
                data.get("target") == target_id
                and data.get("certified") is True
            )
        except Exception:
            return False



    def __init__(self, root):

        self.path = (
            Path(root)
            /
            "builder/python/wlplatform/src/wlplatform/runtime/targets/registry.json"
        )

        if not self.path.exists():
            raise FileNotFoundError(
                f"Runtime target registry missing: {self.path}"
            )

        with self.path.open() as f:
            self.data = json.load(f)


    def get(self, name):

        runtimes = self.data.get(
            "runtimes",
            {}
        )

        if name not in runtimes:
            raise ValueError(
                f"Unknown runtime target: {name}"
            )

        return runtimes[name]


    def list(self):

        return list(
            self.data.get(
                "runtimes",
                {}
            ).keys()
        )
