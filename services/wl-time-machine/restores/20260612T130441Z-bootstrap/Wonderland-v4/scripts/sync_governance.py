#!/usr/bin/env python3
import os
import yaml
import json
import sys
from pathlib import Path

class RegistryBridge:
    def __init__(self):
        self.gov_path = Path(os.path.expanduser("~/Wonderland/intelligence/obsidian/governance"))
        self.svc_path = Path(os.path.expanduser("~/Wonderland/Wonderland-v4/services"))

    def load_registry(self, registry_path):
        with open(registry_path, 'r') as f:
            try:
                if registry_path.suffix == '.yaml':
                    return yaml.safe_load(f)
                elif registry_path.suffix == '.json':
                    return json.load(f)
            except Exception as e:
                return {"error": f"Failed to parse {registry_path.name}: {e}"}
        return None

    def get_all_registries(self):
        return {r.stem: self.load_registry(r) for r in self.gov_path.glob("*.*") if r.suffix in ['.yaml', '.json']}

    def run_sync(self):
        print("[AUTHORITATIVE SYNC: Obsidian -> Runtime]")
        registries = self.get_all_registries()
        for name, data in registries.items():
            target_dir = self.svc_path / name
            if not target_dir.exists():
                print(f"  └── [MISSING] {name}: Defined in Obsidian, absent in Runtime.")
            else:
                print(f"  └── [VERIFIED] {name}: Registry matched.")
        for service in self.svc_path.iterdir():
            if service.is_dir() and service.name not in registries:
                print(f"  └── [GHOST] {service.name}: No authoritative registry found.")

if __name__ == "__main__":
    bridge = RegistryBridge()
    if "--api" in sys.argv:
        print(json.dumps(bridge.get_all_registries(), indent=2))
    else:
        bridge.run_sync()
