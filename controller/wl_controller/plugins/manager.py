from __future__ import annotations

import importlib.util
import traceback
from pathlib import Path

from wl_controller.plugins.base import PluginContext


class PluginManager:
    def __init__(self, root: Path, controller_version: str):
        self.root = root
        self.plugin_dir = root / "plugins"
        self.context = PluginContext(str(root), controller_version)
        self.plugins: list[object] = []
        self.errors: list[str] = []

    def discover(self) -> None:
        self.plugins = []
        self.errors = []
        self.plugin_dir.mkdir(parents=True, exist_ok=True)

        for path in sorted(self.plugin_dir.glob("*.py")):
            if path.name.startswith("_"):
                continue

            try:
                spec = importlib.util.spec_from_file_location(path.stem, path)
                if spec is None or spec.loader is None:
                    raise RuntimeError(f"unable to load {path}")

                module = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(module)

                plugin = module.plugin()
                plugin.initialize(self.context)
                self.plugins.append(plugin)
            except Exception:
                self.errors.append(f"{path.name}: {traceback.format_exc()}")

    def before_cycle(self) -> None:
        for plugin in self.plugins:
            try:
                getattr(plugin, "before_cycle", lambda: None)()
            except Exception:
                self.errors.append(f"{getattr(plugin, 'name', 'unknown')}: before_cycle failed")

    def after_cycle(self, state: dict) -> None:
        for plugin in self.plugins:
            try:
                getattr(plugin, "after_cycle", lambda _state: None)(state)
            except Exception:
                self.errors.append(f"{getattr(plugin, 'name', 'unknown')}: after_cycle failed")

    def on_event(self, event: dict) -> None:
        for plugin in self.plugins:
            try:
                getattr(plugin, "on_event", lambda _event: None)(event)
            except Exception:
                self.errors.append(f"{getattr(plugin, 'name', 'unknown')}: on_event failed")

    def status(self) -> dict:
        return {
            "enabled": True,
            "count": len(self.plugins),
            "plugins": [getattr(p, "name", p.__class__.__name__) for p in self.plugins],
            "errors": self.errors[-20:],
        }
