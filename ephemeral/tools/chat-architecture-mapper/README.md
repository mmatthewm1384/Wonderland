# Chat Architecture Mapper & Auto-Drop — Wonderland Component

**Classification:** OPERATOR EYES ONLY  
**Date:** 2026-06-22  
**Purpose:** Map the complete architecture of this chat/system and provide an automated, auditable drop mechanism into the authoritative ~/Wonderland/vault as a living bitemporal knowledge artifact.

## Files
- `chat-architecture-map.md` — Comprehensive layered map (tools, renders, memory, style, sandbox, Wonderland integration, safety, data flow). The primary deliverable.
- `auto-drop-chat-map.py` — stdlib Python auto-drop companion. Generates timestamped drop in ~/Wonderland/vault/chat-architecture/<timestamp>/ containing the map (MD + JSON) + notice. Follows venv guardrails (no deps), ephemeral style, and wl-compatible patterns.
- `README.md` — This file.

## Quick Start (on Operator Mac)
```bash
cd /path/to/this/dir   # or after copying to Wonderland-v4/scripts/auto-drop-in/

# Dry run first
python3 auto-drop-chat-map.py drop --dry-run

# Real drop (creates timestamped subdir in vault)
python3 auto-drop-chat-map.py drop

# With custom target (testing)
python3 auto-drop-chat-map.py drop --target /tmp/wonderland-test-vault
```

After drop, the artifact is in Vault and can be referenced by future agents, companions, or Operator queries. Previous drops are retained for time-travel/audit (bitemporal).

## Integration
- Extends Ephemeral/Secret Agent Catalog and Zero-Trust Report naturally.
- Recommended: Add to `wl catalog` or create `wl chat-architecture status/doctor/repair` shim if needed.
- New Wonderland components (FSEvent apps, visuals, companions) should reference this map for consistent architecture and ZT posture.
- Auto-drop scripts belong in scripts/auto-drop-in/ per existing modular workflow.

## Verification
```bash
python3 -m py_compile auto-drop-chat-map.py && echo "Syntax OK"
python3 auto-drop-chat-map.py drop --dry-run
ls -la ~/Wonderland/vault/chat-architecture/  # after real drop
```

## Recovery
- Old drops: `find ~/Wonderland/vault/chat-architecture -maxdepth 1 -type d -mtime +90 -exec rm -rf {} +`
- Full rollback of this component: `rm -rf /path/to/this/dir` (no persistent state outside drops).

This mapper ensures the chat architecture remains documented, queryable, and automatically integrated into the Operator's knowledge core without manual intervention. It embodies ephemeral, auditable, simple, and recoverable design.

**Operator has final authority.**
