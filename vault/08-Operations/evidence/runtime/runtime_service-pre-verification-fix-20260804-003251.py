from wlplatform.runtime.targets.loader import RuntimeTargetRegistry
try:
    from wlplatform.runtime.state.store import RuntimeStateStore
except ImportError:
    RuntimeStateStore = None

from ..runtime.certification.writer import RuntimeCertificateWriter
from wlplatform.runtime.adapters.lima_adapter import LimaRuntimeAdapter
from datetime import datetime, timezone
from pathlib import Path

from ..runtime.evidence.lifecycle import (
    RuntimeLifecycleEvidence
)
from ..runtime.inventory import RuntimeInventory

class RuntimeService:

    def _state_store(self):
        return RuntimeStateStore(
            self.root
        )



    def __init__(self, root=None, adapter=None):

        if root:
            self.root = Path(root)
        else:
            from wlplatform.runtime.context import get_context
            self.root = Path(
                get_context().root
            )

        from wlplatform.runtime.targets.loader import (
            RuntimeTargetRegistry
        )

        self.targets = RuntimeTargetRegistry(
            self.root
        )

        self.adapter = adapter



    def _transaction_event(
        self,
        action,
        result
    ):

        import json
        from datetime import datetime, timezone

        event = {
            "service": "runtime",
            "transaction": True,
            "action": action,
            "result": result,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        ledger = (
            self.root
            / "runtime"
            / "events"
            / "runtime-transactions.jsonl"
        )

        ledger.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        with ledger.open("a") as f:
            f.write(
                json.dumps(event)
                + "\n"
            )

        return event

    def _normalize_runtime_result(
        self,
        action,
        result
    ):

        if result is True:
            state = "success"

        elif result is False:
            if action == "stop":
                state = "already_stopped"
            else:
                state = "failed"

        else:
            state = "unknown"

        return {
            "action": action,
            "raw_result": result,
            "state": state,
            "recoverable": state != "unknown"
        }


    def _event(self, action, result):
    
        from ..runtime.evidence.writer import RuntimeEvidenceWriter
    
        lifecycle = RuntimeLifecycleEvidence(
            self.root
        )
    
        lifecycle.write(
            action,
            result
        )
    
        writer = RuntimeEvidenceWriter(
            self.root
        )
    
        return writer.write(
            action,
            result
        )

    def _resolve_runtime(self, target=None):

        if target is None:
            return None

        from pathlib import Path
        import yaml

        registry = (
            self.root
            /
            "runtime"
            /
            "registry"
            /
            "runtime-registry-v1.yaml"
        )

        if registry.exists():

            with open(registry, "r") as f:
                data = yaml.safe_load(f)

            runtime_registry = (
                data
                .get("runtime_registry", {})
            )

            active = (
                runtime_registry
                .get("active", {})
            )

            if target == "host":

                host = active.get(
                    "host"
                )

                if host:

                    return {
                        "id": "host",
                        "instance": host["instance"],
                        "role": host["role"],
                        "provider": host["provider"],
                        "state": "unknown"
                    }


        inventory = RuntimeInventory(
            self.root
        )

        runtimes = inventory.load()

        for runtime in runtimes:

            if runtime.get("id") == target:
                return runtime


        raise ValueError(
            f"unknown runtime target: {target}"
        )

    def certify(self, target=None):

        verification = self.verify(
            target
        )

        writer = RuntimeCertificateWriter(
            self.root
        )

        certificate = writer.write(
            target or "host",
            verification
        )

        return self._event(
            "certify",
            certificate
        )

    def _adapter_for(self, target=None):

        if target in (None, "host", "wonderland-rootless"):
            from wlplatform.runtime.adapters.lima_adapter import (
                LimaRuntimeAdapter
            )

            return LimaRuntimeAdapter(
                "wonderland-rootless"
            )

        if target == "debian":
            from wlplatform.runtime.adapters.lima_adapter import (
                LimaRuntimeAdapter
            )

            return LimaRuntimeAdapter(
                "wonderland-debian-rootless-v1"
            )

        return None

    def start(self, target=None):

        result = self._adapter_for(target).start()

        result = self._normalize_runtime_result(
            "start",
            result
        )

        self._transaction_event(
            "start",
            result
        )

        return self._event(
            "start",
            result
        )


    def stop(self, target=None):

        result = self._adapter_for(target).stop()

        result = self._normalize_runtime_result(
            "stop",
            result
        )

        self._transaction_event(
            "stop",
            result
        )

        return self._event(
            "stop",
            result
        )


    def _resolve_adapter(
        self,
        target
    ):

        config = self.targets.get(
            target
        )

        if config["adapter"] != "lima":
            raise ValueError(
                f"Unsupported runtime adapter: {config['adapter']}"
            )

        return LimaRuntimeAdapter(
            config["instance"]
        )


    def restart(self):

        stop = self.adapter.stop()
        start = self.adapter.start()

        return self._event(
            "restart",
            {
                "stop": stop,
                "start": start,
            }
        )


    def sleep(self):

        return self._event(
            "sleep",
            {
                "state": "sleeping"
            }
        )


    def wake(self):

        return self._event(
            "wake",
            self.adapter.start()
        )


    def status(self, target=None):
    
        inventory = RuntimeInventory(
            self.root
        )
    
        runtimes = []
    
        for runtime in inventory.load():
    
            adapter = LimaRuntimeAdapter(
                runtime["instance"]
            )
    
            runtimes.append(
                {
                    "id": runtime["id"],
                    "instance": runtime["instance"],
                    "role": runtime["role"],
                    "state": adapter.state(),
                    "certified": runtime.get(
                        "certified",
                        False
                    ),
                }
            )
    
        return self._event(
            "status",
            {
                "runtimes": runtimes
            }
        )


    def trust(self, target=None):

        import json
        from datetime import datetime, timezone

        base = (
            self.root
            / "runtime"
            / "certifications"
        )

        verification_path = (
            base
            / f"{target}.verification.json"
        )

        policy_path = (
            base
            / f"{target}.policy.json"
        )

        certification_path = (
            base
            / f"{target}.json"
        )

        required = [
            certification_path,
            verification_path,
            policy_path,
        ]

        missing = [
            str(p)
            for p in required
            if not p.exists()
        ]

        trusted = False
        checks = {}

        if not missing:

            verification = json.loads(
                verification_path.read_text()
            )

            policy = json.loads(
                policy_path.read_text()
            )

            checks = {
                "certification_present": True,
                "verification_passed": (
                    verification.get(
                        "passed",
                        False
                    )
                ),
                "policy_passed": (
                    policy.get(
                        "passed",
                        False
                    )
                ),
            }

            trusted = all(
                checks.values()
            )

        else:

            checks = {
                "missing_artifacts": missing
            }

        result = {
            "service": "runtime",
            "trust": True,
            "target": target,
            "trusted": trusted,
            "checks": checks,
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        path = (
            self.root
            / "runtime"
            / "trust"
            / f"{target}.json"
        )

        path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        path.write_text(
            json.dumps(
                result,
                indent=2
            )
        )

        return self._event(
            "trust",
            result
        )


    def policy_check(self, target=None):

        import json
        from datetime import datetime, timezone

        from ..runtime.policy import RuntimePolicy

        policy = RuntimePolicy(
            self.root
        ).load()

        verification_path = (
            self.root
            / "runtime"
            / "certifications"
            / f"{target}.verification.json"
        )

        if not verification_path.exists():
            raise FileNotFoundError(
                "runtime verification missing"
            )

        verification = json.loads(
            verification_path.read_text()
        )

        required = policy["checks"]

        checks = {}

        for key, required_value in required.items():

            if key == "instance_match_required":
                checks[key] = (
                    verification["checks"]
                    .get("instance_matches", False)
                )
            else:
                checks[key] = (
                    verification["checks"]
                    .get(key, False)
                )

        passed = all(
            checks.values()
        )

        result = {
            "service": "runtime",
            "policy_check": True,
            "target": target,
            "passed": passed,
            "checks": checks,
            "policy": policy["version"],
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        path = (
            self.root
            / "runtime"
            / "certifications"
            / f"{target}.policy.json"
        )

        path.write_text(
            json.dumps(
                result,
                indent=2
            )
        )

        return self._event(
            "policy_check",
            result
        )

    def verify(self, target=None):
    
        if target is None:
            target = "host"
    
        runtime = self._resolve_runtime(target)
    
        if runtime is None:
            return {
                "service": "runtime",
                "action": "verify",
                "target": target,
                "verified": False,
                "error": "runtime target not registered"
            }

        adapter = self._adapter_for(
            target
        )

        checks = {}

        checks["runtime_exists"] = runtime is not None

        checks["adapter_lima"] = (
            adapter is not None
        )

        checks["instance_match"] = (
            runtime["instance"]
            ==
            adapter.instance
        )

        checks["state_available"] = (
            adapter.state()
            !=
            "Unknown"
        )

        evidence = (
            self.root
            /
            "runtime"
            /
            "events"
            /
            "runtime-evidence.jsonl"
        )

        checks["evidence_present"] = (
            evidence.exists()
        )

        verified = all(
            checks.values()
        )

        result = {
            "service": "runtime",
            "action": "verify",
            "target": target,
            "checks": checks,
            "verified": verified
        }

        return result


    def certify(self, target=None):

        from pathlib import Path
        import json
        from datetime import datetime, timezone

        verification = self.verify(
            target
        )

        if not verification.get(
            "verified",
            False
        ):
            raise RuntimeError(
                "runtime verification failed"
            )


        runtime = self._resolve_runtime(target)

        if runtime is None:
            raise ValueError(
                f"unknown runtime target: {target}"
            )

        adapter = self._adapter_for(target)

        inspection = adapter.inspect()

        state = adapter.state()

        certification = {
            "service": "runtime",
            "certification": True,
            "target": target,
            "instance": runtime["instance"],
            "role": runtime["role"],
            "state": state,
            "inspection": inspection,

            "checks": {
                "runtime_registered": True,
                "adapter_resolved": True,
                "runtime_state_available": state is not None,
                "certified_inventory": runtime.get(
                    "certified",
                    False
                ),
            },
            "timestamp": datetime.now(
                timezone.utc
            ).isoformat()
        }

        path = (
            self.root
            / "runtime"
            / "certifications"
            / f"{target}.json"
        )

        path.parent.mkdir(
            parents=True,
            exist_ok=True
        )

        path.write_text(
            json.dumps(
                certification,
                indent=2
            )
        )

        return self._event(
            "certify",
            certification
        )
