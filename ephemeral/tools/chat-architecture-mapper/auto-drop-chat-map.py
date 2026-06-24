#!/usr/bin/env python3
"""
Auto-Drop Chat Architecture Mapper for Wonderland
stdlib-only Python companion.

Generates (or copies) the authoritative Chat Architecture Map
and drops it into ~/Wonderland/vault/chat-architecture/ as a
bitemporal living knowledge artifact.

Follows Wonderland Python guardrails (self-contained, no globals needed,
explicit paths, repair-friendly) and ephemeral style (timestamped drops,
TTL notes, cleanable).

Run on Operator's Mac (where ~/Wonderland/vault exists) or with --target
for testing. Integrates with wl patterns and vault governance.

Usage:
  python3 auto-drop-chat-map.py --help
  python3 auto-drop-chat-map.py drop
  python3 auto-drop-chat-map.py drop --dry-run
  python3 auto-drop-chat-map.py drop --target /tmp/test-vault
"""

import argparse
import json
import os
import sys
import shutil
import datetime
from pathlib import Path
from typing import Optional

VAULT_BASE = Path.home() / "Wonderland" / "vault"
CHAT_SUBDIR = "chat-architecture"
MAP_MD_NAME = "chat-architecture-map.md"
MAP_JSON_NAME = "chat-architecture-map.json"
NOTICE_NAME = "DROP_NOTICE.txt"

# Embedded minimal map for self-contained drop (full prose in companion .md)
# In production this would read from sibling file or regenerate dynamically.
MINIMAL_MAP = {
    "title": "Chat Architecture Map — Wonderland Knowledge Core",
    "version": "2026-06-22",
    "classification": "OPERATOR EYES ONLY",
    "layers": [
        "Core Reasoning (Grok + Wonderland context)",
        "Tool Layer (search, browse, code, image, memory, connected)",
        "Render Layer (citations, images, files)",
        "Memory & Style Enforcement (durable facts, 8-part blueprint)",
        "Sandbox Environment (Linux artifacts, persistent shell)",
        "Wonderland Integration (ephemeral agents, ZT, wl CLI, vault drops)"
    ],
    "data_flow": "Query → Reason (with memory/style) → Parallel tools if needed → Synthesize + renders → Final response",
    "key_tenets": [
        "Recoverability > Convenience",
        "Auditability > Speed",
        "Simplicity > Cleverness",
        "Ephemeral/secret-agent native + Zero-Trust aligned"
    ],
    "drop_metadata": {
        "dropped_at": None,
        "source": "auto-drop-chat-map.py",
        "target": str(VAULT_BASE / CHAT_SUBDIR)
    }
}

def get_drop_dir(target_base: Optional[Path] = None) -> Path:
    base = target_base or VAULT_BASE
    drop_dir = base / CHAT_SUBDIR / datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    return drop_dir

def create_notice(drop_dir: Path, dry_run: bool = False) -> None:
    notice = drop_dir / NOTICE_NAME
    content = f"""Wonderland Vault Auto-Drop Notice
=====================================
Chat Architecture Map dropped at: {datetime.datetime.now().isoformat()}
Source: auto-drop-chat-map.py (self-contained stdlib)
Classification: OPERATOR EYES ONLY
Target (this drop): {drop_dir}
Vault base: {VAULT_BASE}

This is a living bitemporal knowledge artifact.
Previous versions retained for time-travel / audit.
Clean old drops with: find {drop_dir.parent} -maxdepth 1 -type d -mtime +90 -exec rm -rf {{}} +

Integrates with:
- Ephemeral/Secret Agent Catalog
- Zero-Trust Investigation Report
- All wl <service> components
- Intent-driven workflows

Operator has final authority. System runs independently of AI.
"""
    if not dry_run:
        notice.write_text(content)
    else:
        print(f"[DRY-RUN] Would write notice to {notice}")

def drop_map(target_base: Optional[Path] = None, dry_run: bool = False) -> Path:
    drop_dir = get_drop_dir(target_base)
    base = target_base or VAULT_BASE

    if dry_run:
        print(f"[DRY-RUN] Would create drop directory: {drop_dir}")
        create_notice(drop_dir, dry_run=True)
        print(f"[DRY-RUN] Would write {MAP_MD_NAME} and {MAP_JSON_NAME}")
        print(f"[DRY-RUN] Drop target base: {base}")
        return drop_dir

    # Ensure directories
    drop_dir.mkdir(parents=True, exist_ok=True)

    # Write MD (full version from sibling file if present, else minimal)
    md_path = Path(__file__).parent / MAP_MD_NAME
    target_md = drop_dir / MAP_MD_NAME
    if md_path.exists():
        shutil.copy2(md_path, target_md)
    else:
        # Fallback minimal MD
        target_md.write_text("# Chat Architecture Map (minimal fallback)\n\nSee companion files and previous conversation context for full mapping.\n")

    # Write JSON version
    map_json = MINIMAL_MAP.copy()
    map_json["drop_metadata"]["dropped_at"] = datetime.datetime.now().isoformat()
    map_json["drop_metadata"]["target"] = str(drop_dir)
    (drop_dir / MAP_JSON_NAME).write_text(json.dumps(map_json, indent=2) + "\n")

    create_notice(drop_dir)

    print(f"✅ Auto-dropped Chat Architecture Map to: {drop_dir}")
    print(f"   MD: {target_md}")
    print(f"   JSON: {drop_dir / MAP_JSON_NAME}")
    print(f"   Notice: {drop_dir / NOTICE_NAME}")
    print("   This is now part of the authoritative Vault knowledge core.")
    return drop_dir

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Auto-Drop Chat Architecture Mapper — Wonderland Vault integration (ephemeral, auditable, stdlib)"
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("drop", help="Perform the auto-drop of the chat architecture map into Vault")
    p.add_argument("--dry-run", action="store_true", help="Simulate without writing files")
    p.add_argument("--target", type=Path, help="Override vault base (default: ~/Wonderland/vault)")
    p.set_defaults(func=lambda a: drop_map(a.target, a.dry_run))

    args = parser.parse_args()
    if hasattr(args, "func"):
        args.func(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
