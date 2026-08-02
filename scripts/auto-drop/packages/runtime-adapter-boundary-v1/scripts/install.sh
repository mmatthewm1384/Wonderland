#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/wonderland/Wonderland"

TARGET="$ROOT/builder/python/wlplatform/src/wlplatform/runtime"
ADAPTERS="$TARGET/adapters"

mkdir -p "$ADAPTERS"

touch "$TARGET/__init__.py"


cat > "$ADAPTERS/__init__.py" <<'PY'
from .base import RuntimeAdapter
from .lima import LimaAdapter
from .nerdctl import NerdctlAdapter

__all__ = [
    "RuntimeAdapter",
    "LimaAdapter",
    "NerdctlAdapter",
]
PY


cat > "$ADAPTERS/base.py" <<'PY'
from abc import ABC, abstractmethod


class RuntimeAdapter(ABC):

    @abstractmethod
    def start(self):
        raise NotImplementedError

    @abstractmethod
    def stop(self):
        raise NotImplementedError

    @abstractmethod
    def status(self):
        raise NotImplementedError
PY


cat > "$ADAPTERS/lima.py" <<'PY'
from .base import RuntimeAdapter


class LimaAdapter(RuntimeAdapter):

    def start(self):
        return {
            "adapter": "lima",
            "action": "start",
            "status": "ready"
        }


    def stop(self):
        return {
            "adapter": "lima",
            "action": "stop",
            "status": "ready"
        }


    def status(self):
        return {
            "adapter": "lima",
            "state": "unknown"
        }
PY


cat > "$ADAPTERS/nerdctl.py" <<'PY'
from .base import RuntimeAdapter


class NerdctlAdapter(RuntimeAdapter):

    def start(self):
        return {
            "adapter": "nerdctl",
            "action": "start",
            "status": "ready"
        }


    def stop(self):
        return {
            "adapter": "nerdctl",
            "action": "stop",
            "status": "ready"
        }


    def status(self):
        return {
            "adapter": "nerdctl",
            "state": "unknown"
        }
PY


echo "Runtime adapter boundary installed"
