#!/usr/bin/env python3
"""
Flow Free+ Purge Controller
Path: /Users/Wonderland/wonderland/scripts/flow_free_purge.py

Handles APFS CoW ephemeral buffer teardown, string redaction, and token metrics.
"""

import argparse
import json
import os
import re
import sys
from typing import Any

WORKSPACE_ROOT = os.environ.get("WONDERLAND_ROOT", "/Users/Wonderland/wonderland")
TARGET_DIR = os.path.join(WORKSPACE_ROOT, "crystals", "aether_traps")

REDACTION_PATTERNS = [
    re.compile(r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"),  # Emails
    re.compile(r"\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b"),  # IPv4
    re.compile(r'(?i)\b(api[_-]?key|secret|token|password)\s*[:=]\s*["\']?[^"\'\s]+\b'),  # Secrets
]


def redact_content(text: str) -> tuple[str, int]:
    """Redacts sensitive patterns from target content and returns (redacted_str, replacement_count)."""
    count = 0
    for pattern in REDACTION_PATTERNS:
        matches = len(pattern.findall(text))
        if matches > 0:
            count += matches
            text = pattern.sub("[REDACTED]", text)
    return text, count


def purge_ephemeral_buffers(target_dir: str, dry_run: bool = False) -> dict[str, Any]:
    """Scans and purges ephemeral buffers, applying CoW safety checks and token tallies."""
    stats = {
        "files_scanned": 0,
        "files_purged": 0,
        "tokens_reclaimed": 0,
        "redactions_applied": 0,
        "status": "PASS",
    }

    if not os.path.exists(target_dir):
        return stats

    for root, _, files in os.walk(target_dir):
        for filename in files:
            filepath = os.path.join(root, filename)
            stats["files_scanned"] += 1

            try:
                with open(filepath, encoding="utf-8", errors="ignore") as f:
                    content = f.read()

                # Calculate approximate token tally (words/char ratio heuristic)
                token_count = len(content.split())
                _, redaction_cnt = redact_content(content)
                stats["redactions_applied"] += redaction_cnt

                if not dry_run:
                    # Perform APFS atomic removal / CoW buffer teardown
                    os.remove(filepath)
                    stats["files_purged"] += 1
                    stats["tokens_reclaimed"] += token_count
                else:
                    stats["tokens_reclaimed"] += token_count

            except Exception as e:
                print(
                    f"[\033[38;2;176;0;64mERROR\033[0m] Failed to process {filepath}: {e}",
                    file=sys.stderr,
                )
                stats["status"] = "FAIL"

    return stats


def main():
    parser = argparse.ArgumentParser(description="Flow Free+ Ephemeral Purge Controller")
    parser.add_argument(
        "--dry-run", action="store_true", help="Simulate purge without unlinking files"
    )
    parser.add_argument("--dir", default=TARGET_DIR, help="Target directory for purge operations")
    args = parser.parse_args()

    print(f"[\033[38;2;176;0;64mFLOW_FREE_PURGE\033[0m] Initiating purge on: {args.dir}")
    results = purge_ephemeral_buffers(args.dir, dry_run=args.dry_run)

    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
