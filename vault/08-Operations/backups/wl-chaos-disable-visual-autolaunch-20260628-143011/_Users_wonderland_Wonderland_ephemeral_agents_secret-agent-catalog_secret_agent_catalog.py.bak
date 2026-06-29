#!/usr/bin/env python3
"""
Wonderland Secret Agent Catalog Agent
stdlib-only Python microservice companion.

Role: Provide Operator with queryable access to the Ephemeral / Secret Agent Style Compendium.
Ephemeral by design: Can be copied to /tmp, run with mission args, output delivered, then removed.
No global packages. No persistent state unless --persist or Vault drop explicitly requested.

Usage examples:
  python3 secret_agent_catalog.py --help
  python3 secret_agent_catalog.py list-categories
  python3 secret_agent_catalog.py list --category "Visual"
  python3 secret_agent_catalog.py search "slam"
  python3 secret_agent_catalog.py generate-intent "infiltrator-atom" --output /tmp/mission.json
  python3 secret_agent_catalog.py briefing --mission-id $(uuidgen) --style secret-agent

When run with --ephemeral (default for most actions): All generated files use temp dir + TTL note.
"""

import argparse
import json
import os
import sys
import tempfile
import shutil
import datetime
import uuid
from pathlib import Path
from typing import Any, Dict, List, Optional

# =============================================================================
# STRUCTURED COMPENDIUM DATA (Authoritative subset for machine queries)
# Full prose catalog lives in secret-agent-catalog.md (Vault authoritative)
# =============================================================================

COMPENDIUM: Dict[str, List[Dict[str, Any]]] = {
    "Visual & Generative Effects": [
        {
            "id": "infiltrator-atom",
            "name": "Infiltrator / Collector Atoms (Matrix-Style)",
            "description": "Spawn invisibly or low-opacity, collect intel (colors/positions/intents), disperse or slam with harmless waste only. No persistent particle state post-mission.",
            "ephemeral_traits": ["invisible spawn phase", "mission-bounded lifetime", "full memory release on cleanup"],
            "secret_traits": ["observe-only or collect-and-exfil modes", "stealth trajectory calculation"],
            "use_cases": ["data collection without visual trace", "secure slam destruction metaphor"]
        },
        {
            "id": "phantom-wave",
            "name": "Phantom / Ghost Wave Agitators",
            "description": "Perturb flat frequency lines with keyed sine+jitter to embed signals, then restore baseline with zero residue.",
            "ephemeral_traits": ["automatic baseline restoration", "no persistent wave state"],
            "secret_traits": ["frequency-band keyed perturbations (targeted whisper ops)"],
            "use_cases": ["covert signal embedding in visuals", "energize then vanish"]
        },
        {
            "id": "self-erasing-particles",
            "name": "Self-Erasing Particle Systems & Trails",
            "description": "Particles carry explicit max_age or decay; on death they are explicitly removed with zero trail accumulation.",
            "ephemeral_traits": ["per-particle lifetime enforcement", "explicit render list removal"],
            "secret_traits": ["one-time payload carrying (read on impact then destroy)"],
            "use_cases": ["evidence erasure visuals", "temporary non-forensic highlighting"]
        },
        {
            "id": "attention-decay-hooks",
            "name": "Attention Decay Watchers, Rings & Hooks (Spin City)",
            "description": "Rings/trajectories/watchers carry decaying attention_score; below threshold they auto-fade and release resources.",
            "ephemeral_traits": ["self-pruning hooks", "no manual deregistration needed"],
            "secret_traits": ["visualizes cognitive forgetting or mission completion"],
            "use_cases": ["temporary surveillance overlays", "cognitive possibility space viz with built-in expiry"]
        },
        {
            "id": "dead-drop-exchange",
            "name": "Dead Drop Visual Exchanges",
            "description": "Entities rendezvous, transfer payload via morph/blend, then depart divergent paths and de-spawn. No persistent link.",
            "ephemeral_traits": ["one-way handoff", "post-transfer de-spawn"],
            "secret_traits": ["secure visual metaphor for agent-to-agent data exchange"],
            "use_cases": ["secure handoff visualization", "one-time data transfer scenes"]
        },
        {
            "id": "chaos-veil",
            "name": "Chaos Veil / Distraction Burst Generators",
            "description": "On trigger emit dense noise field or rapid waves to mask real actions, then orderly collapse to clean state.",
            "ephemeral_traits": ["strictly bounded duration", "deterministic clean resolution"],
            "secret_traits": ["masks slam/extraction behind plausible visual chaos"],
            "use_cases": ["opsec cover for high-value operations", "attention overload distraction"]
        },
        {
            "id": "covert-rotation",
            "name": "Covert / Phantom Rotation Observers (Spin City)",
            "description": "Outer counter-clockwise patrol + inner clockwise surveillance with easing. Subtle reporting via intensity.",
            "ephemeral_traits": ["mission-window instantiation then full dismantle"],
            "secret_traits": ["non-jarring smooth motion avoids drawing attention"],
            "use_cases": ["perimeter surveillance viz", "dual-layer observer patterns"]
        }
    ],
    "Automation & Scripting Agents": [
        {
            "id": "self-terminating-fsevent",
            "name": "Self-Terminating FSEventStream Agents",
            "description": "Register narrow FSEventStream, deliver on event, then immediately stop/invalidate/release. Post-mission verify empty watch list.",
            "ephemeral_traits": ["zero residual monitoring after mission", "explicit stream release"],
            "secret_traits": ["paths/flags derived from intent at runtime (no hard-coded secrets in binary)"],
            "use_cases": ["triggered agitation or intent execution with clean teardown"]
        },
        {
            "id": "ephemeral-intent-executor",
            "name": "Ephemeral Intent-Driven Mission Executors",
            "description": "Consume intent.json (ephemeral:true, ttl, cleanup_policy), execute action, write ONLY to mission temp, cleanup per policy on end/timeout/failure.",
            "ephemeral_traits": ["mission-scoped temp only", "policy-driven secure cleanup"],
            "secret_traits": ["--stealth mode suppresses non-essential output and prefers memory paths"],
            "use_cases": ["any Wonderland action wrapped as recoverable, auditable, ephemeral mission"]
        },
        {
            "id": "caffeinate-shadow",
            "name": "Caffeinate Shadow / Timed Power Assertion Agents",
            "description": "Wrap critical sections with timed caffeinate or IOPMAssertion. Lifetime bound to mission object; guaranteed release via defer/finally.",
            "ephemeral_traits": ["assertion vanishes exactly at mission end", "no lingering power state"],
            "secret_traits": ["prevents sleep detection while avoiding battery/thermal forensic traces"],
            "use_cases": ["long-running but time-bounded visual generation or data ops"]
        },
        {
            "id": "aether-courier",
            "name": "Aether Memory Couriers (Inter-Agent Comms)",
            "description": "Named pipes or short-lived temp files (0600) for write-once/read-once comms with unlink after. TTL enforced by sweeper or reader timeout.",
            "ephemeral_traits": ["no long-term state", "graceful fail if reader misses window"],
            "secret_traits": ["content can be obfuscated/encrypted blobs for higher classification"],
            "use_cases": ["loose coordination between transient agents without persistent bus"]
        },
        {
            "id": "phantom-process",
            "name": "Phantom / Detached Process Launchers & Reapers",
            "description": "Launch with nohup/setsid, maintain PID in mission temp only, reap on completion/timeout, clean all child artifacts.",
            "ephemeral_traits": ["zero zombie processes or orphan artifacts", "clean ps/top output post-mission"],
            "secret_traits": ["prevents process tree forensic analysis"],
            "use_cases": ["background work that must leave no trace in process list"]
        },
        {
            "id": "burn-after-read",
            "name": "Burn-After-Read / One-Shot Visual or Data Generators",
            "description": "Generate sensitive pattern or blob for single consumption; after display/timeout overwrite buffers or secure-delete backing store.",
            "ephemeral_traits": ["volatile buffers or one-time canvas", "explicit destruction confirmation"],
            "secret_traits": ["visual burn effect optional for high-drama missions"],
            "use_cases": ["one-time mission briefings", "sensitive visual codes that must not persist"]
        }
    ],
    "Custom Companions": [
        {
            "id": "catalog-agent",
            "name": "Catalog Agent (This Implementation)",
            "description": "stdlib Python companion holding structured compendium. CLI for list/search/briefing/generate-intent. Ephemeral launch pattern: /tmp copy → run → remove.",
            "ephemeral_traits": ["no installation", "temp-only generated artifacts with TTL note", "self-contained stdlib"],
            "secret_traits": ["--ephemeral flag forces all outputs through temp with cleanup guidance"],
            "use_cases": ["Operator query interface to this compendium", "mission briefing generation"]
        },
        {
            "id": "watcher-companion",
            "name": "Watcher / Observer Companions",
            "description": "Lightweight event or poll-based observers for FSEvents, dirs, processes, attention. Emit minimal report then clean state or terminate.",
            "ephemeral_traits": ["minimal structured report then prune", "observe-only never-log-to-disk mode available"],
            "secret_traits": ["can be instantiated per-mission and vanish after single observation"],
            "use_cases": ["stealth monitoring of file or visual state changes"]
        },
        {
            "id": "extraction-agent",
            "name": "Extraction, Packaging & Exfil Agents",
            "description": "Pull per intent, package (in-mem or temp), optional obfuscate, deliver to dead-drop/Vault/stdout, verify, then secure cleanup source + temps.",
            "ephemeral_traits": ["mission temp only", "post-delivery verification then purge"],
            "secret_traits": ["leaves clear aether breadcrumbs only on failure for Operator review"],
            "use_cases": ["secure data movement with guaranteed erasure of source"]
        },
        {
            "id": "doctor-agent",
            "name": "Doctor / Repair Agents (Idempotent)",
            "description": "Read-only inspection of processes, temps, assertions, streams. Act ONLY on detected anomalies. Never touch healthy state. wl doctor/repair entrypoint.",
            "ephemeral_traits": ["report-only by default", "idempotent repair safe to run repeatedly"],
            "secret_traits": ["minimal logging; only anomalies generate aether entries"],
            "use_cases": ["post-mission or periodic health verification without side effects"]
        }
    ],
    "State & Architectural Patterns": [
        {
            "id": "bitemporal-ttl",
            "name": "Bitemporal Records with TTL / Erasure",
            "description": "Events recorded with valid_time, transaction_time, expiry_time. Support as-of queries + automatic or on-demand purge of expired secrets.",
            "ephemeral_traits": ["built-in forgetting", "purge = overwrite or unlink"],
            "secret_traits": ["time-travel debugging during mission while guaranteeing eventual erasure"],
            "use_cases": ["audit + secret management in one model"]
        },
        {
            "id": "attention-decay",
            "name": "Attention Decay & Automatic Hook Release",
            "description": "Callbacks, watchers, visuals carry decay model. Sweeper prunes below threshold or after mission window. Prevents resource leaks.",
            "ephemeral_traits": ["self-pruning resources", "no manual cleanup in happy path"],
            "secret_traits": ["visualizes mission progress via decaying attention"],
            "use_cases": ["long-running systems with mostly-idle periods between missions"]
        },
        {
            "id": "graceful-termination",
            "name": "Universal Graceful Termination Protocol",
            "description": "All agents implement SIGTERM/INT/HUP handlers → set flag → minimal safe work → cleanup() → exit. cleanup() releases assertions, streams, temps, aether.",
            "ephemeral_traits": ["idempotent cleanup safe to call multiple times", "guaranteed resource release even on error paths"],
            "secret_traits": ["minimal 'mission terminated cleanly' record only"],
            "use_cases": ["every long-lived or transient component in Wonderland"]
        },
        {
            "id": "vault-dead-drop",
            "name": "Vault Dead Drop Protocol",
            "description": "Standard location ~/Wonderland/vault/dead-drops/<mission_id>/ with 0600 perms. Receivers scan/process then move to archive or shred.",
            "ephemeral_traits": ["short TTL metadata on drops", "scanner itself ephemeral or short-cycle"],
            "secret_traits": ["one-way write; no persistent link back to writer"],
            "use_cases": ["secure one-way agent-to-Operator or agent-to-agent handoff"]
        },
        {
            "id": "intent-mission-orders",
            "name": "Intent JSON as Formal Mission Orders",
            "description": "Every action begins with intent.json containing mission_id, classification, ephemeral, ttl, cleanup_policy, success_criteria, rollback_plan, stealth_level.",
            "ephemeral_traits": ["self-describing operation", "policy-driven cleanup baked in"],
            "secret_traits": ["stealth_level and classification drive runtime behavior"],
            "use_cases": ["root of all auditable, recoverable, ephemeral Wonderland operations"]
        }
    ],
    "macOS / Swift Patterns": [
        {
            "id": "covert-fsevent",
            "name": "Covert FSEventStream Agents",
            "description": "Narrowest path set + flag mask. Callback minimal dispatch. Mission end: Stop → Invalidate → Release. Verify empty watch list post-cleanup.",
            "ephemeral_traits": ["zero residual monitoring", "runtime-derived paths from intent"],
            "secret_traits": ["no hard-coded sensitive locations in binary"],
            "use_cases": ["file-triggered missions with perfect teardown"]
        },
        {
            "id": "transient-window",
            "name": "Transient SwiftUI / AppKit Window & View Agents",
            "description": "Create window/sheet only for mission duration. isReleasedWhenClosed or onDisappear + proper deinit. No retain cycles. Full deallocation after close.",
            "ephemeral_traits": ["mission-scoped UI lifetime", "guaranteed deallocation"],
            "secret_traits": ["one-time briefing HUDs or temporary dashboards that leave no UI state"],
            "use_cases": ["mission briefings", "temporary visual supervision interfaces"]
        },
        {
            "id": "slam-destroy",
            "name": "Slam-to-Ground as Secure Data / Asset Destruction",
            "description": "Visual slam impact at focal point representing secret/asset + code-side secure delete/zeroing. Post-slam verify clean visual + FS/memory state.",
            "ephemeral_traits": ["visual confirmation of sanitization", "code + visual dual verification"],
            "secret_traits": ["powerful metaphor + mechanism for asset sanitized missions"],
            "use_cases": ["secure destruction of files, memory regions, or visual representations of secrets"]
        },
        {
            "id": "power-assertion",
            "name": "IOKit Power Assertion Agents",
            "description": "IOPMAssertionCreateWithName tied to mission lifecycle. defer/finally/context manager guarantees release. Prevents sleep during ops, no lingering assertions.",
            "ephemeral_traits": ["assertion lifetime == mission lifetime", "no forensic battery/thermal traces"],
            "secret_traits": ["timed or event-driven release avoids detection"],
            "use_cases": ["critical visual generation or long compute that must not sleep"]
        },
        {
            "id": "filemanager-stealth",
            "name": "FileManager Stealth & Ephemeral File Ops",
            "description": "Mission files under temporaryDirectory with UUID names. removeItem after use. Optional content overwrite before remove for higher classification.",
            "ephemeral_traits": ["UUID-named temps", "explicit remove + optional overwrite"],
            "secret_traits": ["coordinate with FSEvent for deletion confirmation if audit requires"],
            "use_cases": ["any file operation that must not leave persistent artifacts"]
        }
    ],
    "Security & OpSec": [
        {
            "id": "self-destruct",
            "name": "Embedded Self-Destruct / Burn Logic",
            "description": "Integrity check (hash) at start/mid-mission. On mismatch or burn signal: full cleanup + optional visual burn effect + burn exit code.",
            "ephemeral_traits": ["prevents post-capture analysis", "guaranteed cleanup even on compromise"],
            "secret_traits": ["visual burn effect for Operator reassurance or distraction"],
            "use_cases": ["high-risk missions where capture or tampering is plausible"]
        },
        {
            "id": "burn-after-read-protocol",
            "name": "Burn-After-Read / One-Time Display Protocols",
            "description": "Sensitive content in volatile buffers or one-time canvas. After ack/timeout: clear buffers, dismiss, delete backing. Optional visual destruction confirmation.",
            "ephemeral_traits": ["volatile rendering", "explicit destruction step"],
            "secret_traits": ["high-drama visual confirmation of burn"],
            "use_cases": ["one-time classified briefings or visual codes"]
        },
        {
            "id": "no-trace-mode",
            "name": "Minimal / No-Trace Execution Mode",
            "description": "--stealth or NO_TRACE=1 disables persistent logging. Only ephemeral aether + stdout. All files temp + explicit unlink post-mission.",
            "ephemeral_traits": ["zero persistent artifacts by policy", "stdout + temp aether only"],
            "secret_traits": ["ideal for high-risk or air-gapped style missions"],
            "use_cases": ["maximum opsec Wonderland operations"]
        },
        {
            "id": "honey-canary",
            "name": "Canary / Honey Elements for Observation Detection",
            "description": "Attractive fake files or visuals with known signatures. Any access → immediate Operator alert or auto-escalation to chaos/self-destruct.",
            "ephemeral_traits": ["can be mission-scoped and cleaned with rest of mission"],
            "secret_traits": ["distinguishes real observers from background noise"],
            "use_cases": ["early warning of external interest in mission artifacts"]
        },
        {
            "id": "chaos-escalation",
            "name": "Chaos Escalation & De-escalation Controller",
            "description": "Monitor threat heuristics (CPU, processes, file access, flags). Elevated → visual/process noise + distraction agents + slow real work. Cleared → orderly return to baseline.",
            "ephemeral_traits": ["escalation itself time-bounded and logged", "orderly de-escalation"],
            "secret_traits": ["blends real mission into noise when under observation"],
            "use_cases": ["missions where detection risk is dynamic"]
        }
    ],
    "Launcher & wl Integration": [
        {
            "id": "enhanced-catalog-launcher",
            "name": "Enhanced Ephemeral Catalog Launcher",
            "description": "Supports --style, --mission-timeout, --stealth, --mission-id. Spawns in isolated temp CWD + sanitized env. Tracks active transients for status.",
            "ephemeral_traits": ["isolated spawn context", "automatic child signaling on launcher exit"],
            "secret_traits": ["--stealth reduces logging and uses temp for everything"],
            "use_cases": ["unified entrypoint for all ephemeral/secret-style components"]
        },
        {
            "id": "agent-factory",
            "name": "Agent Factory / Dynamic Generator",
            "description": "Template + intent params → rendered Python/Swift source in mission temp. Optional auto-compile/execute. Post-mission optional auto-delete of generated source.",
            "ephemeral_traits": ["generated source lives only in mission temp", "auto-delete when ephemeral flag set"],
            "secret_traits": ["customized per-mission without leaving template fingerprints"],
            "use_cases": ["on-demand creation of tailored agents for specific missions"]
        },
        {
            "id": "wl-secret-agent-cli",
            "name": "wl secret-agent Command Interface (Standard)",
            "description": "up/down/status/logs/doctor/repair/catalog subcommands. Guarantees uniform, auditable control over all ephemeral and secret-style components.",
            "ephemeral_traits": ["doctor = read-only", "repair = idempotent safe-to-repeat"],
            "secret_traits": ["catalog subcommand delegates to this agent for filtered compendium access"],
            "use_cases": ["Operator single pane of glass for all secret/ephemeral operations"]
        }
    ]
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def get_temp_dir() -> Path:
    """Create a mission-scoped temp directory with cleanup note."""
    tmp = Path(tempfile.mkdtemp(prefix="wonderland-mission-"))
    note = tmp / "EPHEMERAL_NOTICE.txt"
    note.write_text(
        "This directory contains ephemeral mission artifacts.\n"
        "It should be removed after mission completion or TTL expiry.\n"
        f"Created: {datetime.datetime.now().isoformat()}\n"
        "Run 'wl secret-agent repair' or manual rm -rf if orphaned.\n"
    )
    return tmp

def format_item(item: Dict[str, Any], verbose: bool = False) -> str:
    """Pretty format a single compendium item."""
    lines = [f"• {item['name']} (id: {item['id']})"]
    lines.append(f"  {item['description']}")
    if verbose:
        if item.get("ephemeral_traits"):
            lines.append("  Ephemeral traits:")
            for t in item["ephemeral_traits"]:
                lines.append(f"    - {t}")
        if item.get("secret_traits"):
            lines.append("  Secret agent traits:")
            for t in item["secret_traits"]:
                lines.append(f"    - {t}")
        if item.get("use_cases"):
            lines.append("  Use cases:")
            for u in item["use_cases"]:
                lines.append(f"    - {u}")
    return "\n".join(lines)

def search_compendium(keyword: str, category: Optional[str] = None) -> List[Dict[str, Any]]:
    """Search across categories or within one."""
    results = []
    kw = keyword.lower()
    cats = [category] if category else list(COMPENDIUM.keys())
    for cat in cats:
        if cat not in COMPENDIUM:
            continue
        for item in COMPENDIUM[cat]:
            haystack = " ".join([
                item.get("name", ""),
                item.get("description", ""),
                " ".join(item.get("ephemeral_traits", [])),
                " ".join(item.get("secret_traits", [])),
                " ".join(item.get("use_cases", []))
            ]).lower()
            if kw in haystack:
                results.append({"category": cat, **item})
    return results

def generate_sample_intent(agent_id: str, mission_id: Optional[str] = None) -> Dict[str, Any]:
    """Generate a sample intent.json for a given agent/pattern id."""
    if not mission_id:
        mission_id = str(uuid.uuid4())
    now = datetime.datetime.now().isoformat()
    intent = {
        "mission_id": mission_id,
        "classification": "OPERATOR EYES ONLY",
        "created": now,
        "ephemeral": True,
        "ttl_seconds": 300,
        "cleanup_policy": "secure",
        "stealth_level": "standard",
        "success_criteria": "Agent completes core action and reports clean termination via aether",
        "rollback_plan": "Run wl secret-agent repair; manually inspect ~/Wonderland/vault/dead-drops if needed",
        "target_agent_id": agent_id,
        "intent_version": "1.0"
    }
    # Add a couple of example params for common agents
    if "atom" in agent_id or "infiltrator" in agent_id:
        intent["parameters"] = {"spawn_mode": "invisible", "collect_targets": ["color", "intent"], "slam_on_exit": True}
    elif "wave" in agent_id:
        intent["parameters"] = {"agitation_intensity": 0.7, "restore_baseline": True, "keyed_bands": ["red", "alpha"]}
    elif "fsevent" in agent_id:
        intent["parameters"] = {"watch_paths": ["/tmp/mission-input"], "event_mask": ["create", "modify"]}
    return intent

# =============================================================================
# CLI ACTIONS
# =============================================================================

def cmd_list_categories(args: argparse.Namespace) -> None:
    print("Available categories in Wonderland Ephemeral/Secret Agent Compendium:\n")
    for i, cat in enumerate(COMPENDIUM.keys(), 1):
        count = len(COMPENDIUM[cat])
        print(f"  {i}. {cat} ({count} patterns)")

def cmd_list(args: argparse.Namespace) -> None:
    cat = args.category
    if cat and cat not in COMPENDIUM:
        print(f"ERROR: Unknown category '{cat}'. Use 'list-categories' to see valid options.", file=sys.stderr)
        sys.exit(1)
    cats = [cat] if cat else list(COMPENDIUM.keys())
    for c in cats:
        print(f"\n=== {c} ===")
        for item in COMPENDIUM[c]:
            print(format_item(item, verbose=args.verbose))

def cmd_search(args: argparse.Namespace) -> None:
    results = search_compendium(args.keyword, args.category)
    if not results:
        print(f"No matches for keyword '{args.keyword}'" + (f" in category '{args.category}'" if args.category else ""))
        return
    print(f"Found {len(results)} matching pattern(s):\n")
    for r in results:
        print(f"[{r['category']}]")
        print(format_item(r, verbose=args.verbose))
        print()

def cmd_generate_intent(args: argparse.Namespace) -> None:
    intent = generate_sample_intent(args.agent_id, args.mission_id)
    if args.output:
        out_path = Path(args.output)
        out_path.write_text(json.dumps(intent, indent=2) + "\n")
        print(f"Sample intent written to {out_path}")
        if args.ephemeral:
            print("NOTE: This file is in a mission temp context. Remove after use or let TTL expire.")
    else:
        print(json.dumps(intent, indent=2))

def cmd_briefing(args: argparse.Namespace) -> None:
    """Generate a human-readable mission briefing filtered by style or keyword."""
    style = args.style.lower() if args.style else "all"
    print("=" * 70)
    print("WONDERLAND MISSION BRIEFING")
    print(f"Mission ID: {args.mission_id or str(uuid.uuid4())}")
    print(f"Style filter: {style}")
    print(f"Generated: {datetime.datetime.now().isoformat()}")
    print("=" * 70)
    print("\nRelevant patterns from Ephemeral / Secret Agent Compendium:\n")

    keyword_map = {
        "ephemeral": "ephemeral",
        "secret-agent": "secret",
        "stealth": "stealth",
        "all": ""
    }
    kw = keyword_map.get(style, style)
    results = []
    if kw:
        results = search_compendium(kw)
    else:
        # All: pick 2-3 representative from each category
        for cat, items in COMPENDIUM.items():
            results.extend([{"category": cat, **it} for it in items[:2]])

    for r in results[:12]:  # Limit briefing length
        print(f"• [{r['category']}] {r['name']}")
        print(f"  {r['description'][:180]}...")
        print()

    print("\n--- End of Briefing ---")
    print("For full details run: wl secret-agent catalog list")
    print("To launch a specific pattern as mission: wl secret-agent up --mission intent.json")

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Wonderland Secret Agent Catalog Agent — Ephemeral stdlib companion",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""Examples:
  python3 secret_agent_catalog.py list-categories
  python3 secret_agent_catalog.py list --category "Visual & Generative Effects" --verbose
  python3 secret_agent_catalog.py search "slam OR chaos"
  python3 secret_agent_catalog.py generate-intent infiltrator-atom --output /tmp/intent.json
  python3 secret_agent_catalog.py briefing --style secret-agent --mission-id $(uuidgen)
"""
    )
    parser.add_argument("--ephemeral", action="store_true", default=True,
                        help="Force all generated artifacts through temp dir with TTL notice (default: True)")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # list-categories
    p = subparsers.add_parser("list-categories", help="List all available categories")
    p.set_defaults(func=cmd_list_categories)

    # list
    p = subparsers.add_parser("list", help="List patterns (optionally filtered by category)")
    p.add_argument("--category", help="Limit to specific category")
    p.add_argument("--verbose", "-v", action="store_true", help="Show traits and use cases")
    p.set_defaults(func=cmd_list)

    # search
    p = subparsers.add_parser("search", help="Search patterns by keyword across categories")
    p.add_argument("keyword", help="Keyword or phrase to search (supports simple OR)")
    p.add_argument("--category", help="Limit search to one category")
    p.add_argument("--verbose", "-v", action="store_true")
    p.set_defaults(func=cmd_search)

    # generate-intent
    p = subparsers.add_parser("generate-intent", help="Generate sample intent.json for a pattern id")
    p.add_argument("agent_id", help="Pattern id (e.g. infiltrator-atom, phantom-wave, self-terminating-fsevent)")
    p.add_argument("--mission-id", help="Override mission_id (default: new UUID)")
    p.add_argument("--output", "-o", help="Write to file instead of stdout")
    p.set_defaults(func=cmd_generate_intent)

    # briefing
    p = subparsers.add_parser("briefing", help="Generate a filtered human-readable mission briefing")
    p.add_argument("--style", choices=["ephemeral", "secret-agent", "stealth", "all"], default="secret-agent",
                   help="Filter patterns relevant to style")
    p.add_argument("--mission-id", help="Mission identifier for the briefing header")
    p.set_defaults(func=cmd_briefing)

    args = parser.parse_args()

    # Ephemeral mode setup
    if args.ephemeral and hasattr(args, "output") and args.output is None and args.command in ("generate-intent",):
        # For generate-intent without explicit output, suggest temp
        tmpdir = get_temp_dir()
        default_out = tmpdir / f"intent-{args.agent_id}.json"
        print(f"EPHEMERAL MODE: Using temp output {default_out}")
        args.output = str(default_out)

    try:
        args.func(args)
    except KeyboardInterrupt:
        print("\nMission aborted by Operator (SIGINT). Cleaning up...", file=sys.stderr)
        sys.exit(130)
    except Exception as e:
        print(f"FATAL: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
