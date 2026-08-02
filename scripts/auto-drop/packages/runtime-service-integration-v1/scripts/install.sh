#!/bin/sh
set -eu

WL_ROOT="${WL_ROOT:-/Users/wonderland/Wonderland}"

SERVICE="$WL_ROOT/builder/python/wlplatform/src/wlplatform/runtime/integration.py"

mkdir -p "$(dirname "$SERVICE")"

cat > "$SERVICE" <<'PY'
from wlplatform.runtime.targets.resolver import RuntimeTargetResolver
from wlplatform.runtime.adapters.lima import LimaAdapter


class RuntimeIntegration:

    def __init__(self, registry):
        self.resolver = RuntimeTargetResolver(
            registry
        )

    def execute(self, action, target=None):

        config = self.resolver.resolve(
            target
        )

        adapter = config.get(
            "adapter"
        )

        if adapter == "lima":

            instance = config.get(
                "instance"
            )

            runtime = LimaAdapter(
                instance
            )

            handler = getattr(
                runtime,
                action,
                None
            )

            if handler is None:
                raise ValueError(
                    f"unsupported runtime action: {action}"
                )

            return handler()

        raise ValueError(
            f"unsupported runtime adapter: {adapter}"
        )
PY

echo "runtime service integration installed"
