from wlplatform.runtime.targets.loader import RuntimeTargetRegistry
try:
    from wlplatform.runtime.state.store import RuntimeStateStore
except ImportError:
    RuntimeStateStore = None

from wlplatform.runtime.adapters.lima_adapter import LimaRuntimeAdapter
from datetime import datetime, timezone
from pathlib import Path

from ..runtime.adapters import LimaAdapter
from ..runtime.inventory import RuntimeInventory
from ..paths import repository_root

class RuntimeService:

    def _state_store(self):
        return RuntimeStateStore(
            self.root
        )



    def __init__(self, root=None, adapter=None):

        self.root = (
            Path(root)
            if root
            else repository_root()
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
                + "\\n"
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

        from ..runtime.evidence import RuntimeEvidenceWriter

        writer = RuntimeEvidenceWriter(
            self.root
        )

        return writer.write(
            action,
            result
        )

    def _resolve_runtime(self, target=None):

        inventory = RuntimeInventory(
            self.root
        )

        runtimes = inventory.load()

        if target is None:
            return None

        for runtime in runtimes:
            if runtime["id"] == target:
                return runtime

        raise ValueError(
            f"unknown runtime target: {target}"
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

        return LimaAdapter(
            instance=config["instance"]
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
    
            adapter = LimaAdapter(
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


    def shell(self, target=None):

        return self._adapter_for(target).shell()
