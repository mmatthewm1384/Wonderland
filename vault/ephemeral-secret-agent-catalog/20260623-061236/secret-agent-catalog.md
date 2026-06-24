# Wonderland Ephemeral / Secret Agent Style Compendium

**Classification:** OPERATOR EYES ONLY — Matthew Mahaney  
**Date:** 2026-06-22  
**Version:** 1.0.0  
**Status:** Living Document — Extend via Vault drops or agent-generated updates  
**Core Principle:** Every pattern listed here must support recoverability (explicit cleanup), auditability (minimal traceable artifacts), and simplicity (no unnecessary cleverness). AI advises; Operator commands.

---

## Purpose
This compendium catalogs **all** concepts, visual effects, automation patterns, architectural elements, and implementation techniques across the Wonderland ecosystem that can be realized in an **ephemeral** (transient, self-terminating, TTL-bound, trace-minimizing) or **secret agent** (covert, stealthy, mission-driven, watcher/extractor, burn-after-use) style.

Use this as the authoritative reference when designing new agents, extending the Ephemeral Catalog Launcher, or planning missions.

---

## 1. Visual & Generative Effects (Ephemeral / Stealth)

### 1.1 Infiltrator / Collector Atoms (Matrix-Style)
- **Spawn Phase:** Low-opacity or fully invisible entry with trajectory calculated to minimize visual attention. Use phase-in easing.
- **Collection Phase:** Sample colors, positions, or intent data from target elements without altering them visibly.
- **Disperse / Slam Phase:** Blend collected intel into background or execute controlled slam that "destroys" the representation while emitting only harmless waste (fading pixels or zero alpha).
- **Ephemeral Guarantee:** No particle or data structure survives mission end. All memory released in deinit / cleanup.
- **Secret Agent Trait:** Can operate in "observe only" mode or "collect-and-exfil" mode depending on intent flag.

### 1.2 Phantom / Ghost Wave Agitators
- Perturb flat or stale frequency lines using controlled sine + jitter to encode signals or energize regions.
- After agitation window (tied to mission duration), smoothly restore baseline or zero state with no visible residue or frequency shift.
- **Key:** Perturbation can be frequency-band keyed (specific image regions or data channels) for targeted "whisper" operations.
- **Ephemeral Trait:** State machine returns to clean "flat" state automatically; no persistent wave memory.

### 1.3 Self-Erasing Particle Systems & Trails
- Every particle carries explicit `max_age`, decay function, or mission-bounded lifetime.
- On death: Explicit removal from render list + any associated data; path/trail is zeroed or never accumulated.
- Ideal for "evidence erasure" visuals or temporary highlighting that must not leave forensic traces.
- **Secret Trait:** Particles can carry one-time payloads (color/intent) that are "read" on impact then destroyed.

### 1.4 Attention Decay Watchers, Rings & Hooks (Spin City Extension)
- Rings, trajectories, watchers, and hooks carry an `attention_score` that decays linearly or exponentially based on time or "satisfied" conditions.
- When score drops below threshold: Auto-fade visual, remove hook from event system, release resources.
- Visualizes cognitive "forgetting" or mission completion. Perfect for temporary surveillance overlays.
- **Ephemeral:** Hooks self-prune; no manual deregistration needed in normal flow.

### 1.5 Dead Drop Visual Exchanges
- Two or more visual entities rendezvous at a calculated point.
- Transfer occurs via color blend, shape morph, or data payload exchange.
- Post-transfer: Entities depart along divergent paths and de-spawn cleanly.
- No persistent visual or data link remains between participants.
- **Agent Use Case:** Visual metaphor for secure one-way data handoff between ephemeral components.

### 1.6 Chaos Veil / Distraction Burst Generators
- On trigger (high-value action start or detected observation): Emit dense particle field, rapid wave noise, or visual overload to overwhelm observer attention.
- Duration strictly limited to critical phase of mission.
- Resolution: Orderly, deterministic collapse back to clean, stable visual state.
- **OpSec Value:** Masks real slam, extraction, or data operation behind plausible visual chaos.

### 1.7 Covert / Phantom Rotation Observers (Spin City)
- Outer ring: Counter-clockwise patrol / perimeter sweep.
- Inner ring or core: Clockwise focused surveillance of inner content or data.
- Easing functions ensure motion is smooth and non-jarring (does not draw attention).
- Subtle color or intensity shifts can "report" observations without explicit UI.
- **Ephemeral:** Rotation groups can be instantiated for a mission window then fully dismantled.

---

## 2. Automation Scripts, Launchers & Process Agents

### 2.1 Self-Terminating FSEventStream Agents
- Register `FSEventStream` only for the exact paths and event flags required by the mission.
- On relevant event: Deliver payload (e.g., trigger image agitation or intent execution), then immediately stop, invalidate, and release the stream.
- Post-mission verification: Confirm `FSEventStreamCopyPathsBeingWatched` returns empty and no callbacks remain registered.
- **Ephemeral Guarantee:** Zero residual file system monitoring after mission.

### 2.2 Ephemeral Intent-Driven Mission Executors
- Accept structured `intent.json` containing at minimum: `mission_id`, `ephemeral: true`, `ttl_seconds`, `cleanup_policy` ("secure" | "standard"), `success_criteria`.
- Execute core action (agitate_lines, slam, wave perturbation, etc.).
- All outputs written exclusively to mission-scoped temp locations.
- On completion, timeout, or failure: Execute cleanup per policy (remove inputs/outputs, release handles, purge aether entries).
- **Secret Agent Trait:** Can operate with `--stealth` flag that suppresses all non-essential output and uses memory-only paths where feasible.

### 2.3 Caffeinate Shadow / Timed Power Assertion Agents
- Wrap critical mission sections with timed `caffeinate -t <seconds>` or equivalent `IOPMAssertionCreateWithName` + `IOPMAssertionRelease`.
- Assertion lifetime is strictly bound to mission object lifecycle (use `defer` / `finally` / context manager).
- On unexpected termination paths: Handlers guarantee release to prevent battery/thermal detection or resource leaks.
- **Ephemeral:** Assertion disappears exactly when mission ends; no persistent power state change.

### 2.4 Aether Memory Couriers (Inter-Agent Communication)
- Preferred transport: Named pipes (`mkfifo`) or short-lived temp files in `/tmp` or mission temp dir with `0600` perms.
- Protocol: Write-once / read-once (or read-with-acknowledgement), then immediate `unlink`.
- TTL enforced by separate sweeper or reader timeout.
- If reader misses window: Mission fails gracefully with recoverable error; no dangling state.
- **Secret Trait:** Content can be simple JSON or obfuscated/encrypted blobs for higher classification missions.

### 2.5 Phantom / Detached Process Launchers & Reapers
- Launch background work with `nohup`, `setsid`, or `subprocess` with proper detachment.
- Parent maintains lightweight PID file or process group reference in mission temp dir only.
- On child completion or timeout: Parent reaps zombie, removes PID file, cleans any child-generated temps.
- Prevents process tree pollution and ensures clean `ps` / `top` output post-mission.

### 2.6 Burn-After-Read / One-Shot Visual or Data Generators
- Generate sensitive visual pattern, code image, or data blob intended for single consumption.
- After display, acknowledgement, or timeout: Overwrite source buffers (memset) or perform secure delete on backing file.
- Visual confirmation of burn (e.g., particle disintegration of the displayed content) optional for high-drama missions.

---

## 3. Custom Companions (Python stdlib Microservices)

### 3.1 Catalog Agent (This Implementation)
- Self-contained stdlib Python companion that holds the structured compendium.
- Supports CLI queries: list categories, show items by category or keyword, generate sample mission intent JSON, export filtered briefing.
- **Ephemeral Launch Pattern:** Can be copied to `/tmp`, executed with mission-specific args, output delivered to stdout or temp report, then caller removes the script copy. No installation required.
- When `--ephemeral` flag used: All generated artifacts (reports, intent files) are created in temp with explicit TTL note and auto-suggestion for cleanup.

### 3.2 Watcher / Observer Companions
- Lightweight, event-driven or poll-based observers for FSEvents, directory changes, process state, or visual attention metrics.
- On trigger: Emit minimal structured report (`mission_id`, `timestamp`, `observation_type`, `payload_hash`) to aether or stdout.
- Immediately clean internal state and either terminate (preferred for one-shot) or return to dormant low-resource state.
- **Secret Trait:** Can be configured with "observe-only, never-log-to-disk" mode.

### 3.3 Extraction, Packaging & Exfil Agents
- Pull artifacts or data from source locations per intent.
- Package (in-memory tar/zip or temp file), optionally apply lightweight obfuscation or encryption.
- Deliver to designated dead-drop, Vault path, or stdout stream.
- Post-delivery verification (hash or ack), then secure cleanup of source artifacts and all temps per cleanup_policy.
- **Recoverability:** On failure, leaves clear breadcrumbs in aether for Operator review and manual rollback if needed.

### 3.4 Doctor / Repair Agents (Idempotent State Inspectors)
- Perform read-only inspection of system state: running processes, temp file ages, power assertions, open FSEvent streams, orphan artifacts.
- Only act when clear deviation from healthy baseline is detected.
- Actions are strictly limited to remediation of detected issues (e.g., release leaked assertion, unlink stale temp > TTL).
- Never modify healthy, in-spec state. Always report what was found and what (if anything) was repaired.
- **wl Integration:** Invoked via `wl secret-agent doctor` and `wl secret-agent repair`.

### 3.5 Coordination Bus & Heartbeat Agents
- Lightweight bus implemented via append-only temp log or set of mission-scoped files with automatic expiry.
- Ephemeral agents post heartbeats, status updates, or results with short TTL.
- Bus cleaner (can be same agent or separate sweeper) purges expired entries on each run or on timer.
- Enables loose coordination between multiple transient agents without persistent infrastructure.

---

## 4. State Management, Data & Architectural Patterns

### 4.1 Bitemporal Records with Built-in TTL / Erasure
- Every sensitive state change or event is recorded with:
  - `valid_time` (mission clock time when event occurred)
  - `transaction_time` (when it was durably recorded)
  - `expiry_time` (when it must be forgotten or erased)
- Queries support "as-of" semantics, but expired records are candidates for automatic or on-demand purge (overwrite or unlink).
- Supports time-travel debugging during active mission while guaranteeing eventual forgetting of secrets.

### 4.2 Attention Decay & Automatic Hook / Resource Release
- Any registered callback, watcher, visual element, or resource handle carries a decay model.
- Background or event-driven sweeper periodically evaluates and prunes items whose attention/interest has decayed below threshold or whose mission window has closed.
- Prevents slow resource leaks in systems that are long-running but mostly idle between missions.

### 4.3 Universal Graceful Termination & Cleanup Protocol
- Every agent and long-lived component MUST implement:
  - Handlers for `SIGTERM`, `SIGINT`, `SIGHUP` (and `SIGUSR1`/`SIGUSR2` for custom signals).
  - On signal: Set shutdown flag, complete only minimal safe work, invoke `cleanup()`, exit with mission-appropriate code.
- `cleanup()` contract: Release all power assertions, close and invalidate streams, unlink all mission temps, flush aether, emit minimal "mission terminated cleanly" record.
- Idempotent: Calling cleanup multiple times is safe and has no additional side effects.

### 4.4 Vault Dead Drop Protocol
- Standard drop location: `~/Wonderland/vault/dead-drops/<mission_id>/`
- Files written with restrictive permissions (`0600`), unique names, and optional short TTL metadata.
- Receiver agents (or Operator) scan, process or archive, then move to `~/Wonderland/vault/archive/` or perform secure shred.
- Scanner / pickup agent itself follows ephemeral lifecycle.

### 4.5 Intent JSON as Formal Mission Orders
- Every significant action in Wonderland begins with a well-formed `intent.json`.
- Mandatory fields for ephemeral/secret missions: `mission_id` (UUIDv4), `classification`, `ephemeral: bool`, `ttl_seconds`, `cleanup_policy`, `success_criteria`, `rollback_plan`, `stealth_level`.
- This single artifact makes the entire operation auditable, recoverable, and self-describing.

---

## 5. macOS / Swift Specific Implementation Patterns

### 5.1 Covert FSEventStream Agents
- Create stream with `FSEventStreamCreate` using the narrowest possible path set and event flag mask.
- Callback performs minimal work then dispatches to handler (avoid blocking runloop).
- Mission end: `FSEventStreamStop` → `FSEventStreamInvalidate` → `FSEventStreamRelease`.
- Post-cleanup verification: `FSEventStreamCopyPathsBeingWatched` must be empty; no residual callbacks in memory graph.
- **Secret Trait:** Paths and flags can be derived from intent at runtime to avoid hard-coded sensitive locations in binary.

### 5.2 Transient SwiftUI / AppKit Window & View Agents
- Instantiate `NSWindow` or SwiftUI `WindowGroup` / sheet only for the duration of the mission briefing or visualization.
- Set `isReleasedWhenClosed = true` (AppKit) or rely on `.onDisappear` + proper model deinitialization (SwiftUI).
- Present for limited time or until explicit dismiss / timeout signal.
- Guarantee: No strong reference cycles; window and view controllers are fully deallocated after close.
- **Ephemeral Use:** Perfect for one-time "mission briefing" HUDs or temporary visual dashboards.

### 5.3 Slam-to-Ground as Secure Data / Asset Destruction
- Visual slam repurposed: Accelerating particles or objects impact a focal point representing the "secret" or asset.
- On impact: Visual destruction animation + code-side secure delete / zeroing of the corresponding file or memory region.
- Post-slam verification: Confirm visual state is clean and file system / memory audit shows no remnants.
- Powerful metaphor and mechanism for "asset sanitized" missions.

### 5.4 IOKit Power Assertion Agents (caffeinate equivalent in code)
- Create assertion with `IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep, ...)` or timed variant.
- Lifetime strictly coupled to mission object (init acquires, deinit or explicit release relinquishes).
- Use `defer` blocks, `finally`, or context managers for guaranteed release even on error paths.
- Prevents system sleep during critical ops while ensuring no lingering assertions that could be detected via `pmset` or battery logs.

### 5.5 FileManager Stealth & Ephemeral File Operations
- Always create mission files under `FileManager.default.temporaryDirectory` or app-specific cache dir with UUID-based names.
- After use: `try fileManager.removeItem(at:)` 
- For higher classification: Overwrite file content with zeros (or random) before removal (note: SSD wear-leveling limits physical guarantees).
- Coordinate with FSEventStream to optionally wait for deletion event confirmation if audit requires it.

---

## 6. Security, OpSec, Chaos & Self-Protection Patterns

### 6.1 Embedded Self-Destruct / Burn Logic
- Critical agents perform lightweight integrity check (hash of key resources or binary) at start and mid-mission.
- On mismatch, explicit "burn" signal, or timeout: Trigger full cleanup + optional visual "burn" effect, then exit with burn-specific status code.
- Prevents post-capture analysis or reverse engineering of mission parameters.

### 6.2 Burn-After-Read / One-Time Display Protocols
- Sensitive briefings or data visualizations rendered into volatile buffers or one-time canvas textures.
- After user acknowledgement or timeout: Clear buffers (secure memset), dismiss view, delete any backing store.
- Optional visual confirmation of destruction for Operator reassurance.

### 6.3 Minimal / No-Trace Execution Mode
- Global or per-mission `--stealth` / `NO_TRACE=1` flag disables all persistent logging.
- Only ephemeral aether (temp files/pipes) + stdout allowed for output.
- All file operations use temp locations with explicit post-mission unlink.
- Ideal for high-risk or air-gapped style missions inside the ecosystem.

### 6.4 Canary / Honey Elements for Observation Detection
- Deploy attractive but fake files, visual elements, or API endpoints with known access signatures.
- Any access triggers immediate alert to Operator (or auto-escalation to chaos mode / self-destruct).
- Distinguishes genuine external observation from normal background activity.

### 6.5 Chaos Escalation & De-escalation Controller
- Simple heuristics monitor "threat level": CPU/process spikes, unexpected file access, explicit Operator flag, or attention metrics.
- Elevated threat → Increase visual/process noise (spawn distraction agents, ramp wave agitation, slow real work to blend into noise).
- Threat cleared → Orderly de-escalation to baseline behavior and mission pace.
- All escalations are themselves logged with reason, duration, and outcome for post-mission audit and learning.

---

## 7. Launcher, Catalog Integration & wl CLI Patterns

### 7.1 Enhanced Ephemeral Catalog Launcher
- Extended flags: `--style=ephemeral|secret-agent|standard`, `--mission-timeout=SECONDS`, `--stealth`, `--mission-id=UUID`.
- Spawns target agent in isolated context: fresh temp working directory, sanitized environment variables, minimal inherited state.
- Maintains lightweight registry of active transient agents for status queries.
- On launcher exit or timeout: Signals all children for graceful shutdown and reaps.

### 7.2 Agent Factory / Dynamic Generator
- Takes base template (Python or Swift) + intent parameters → renders customized agent source.
- Writes generated source to mission-scoped secure temp location.
- Optionally auto-compiles (Swift) or executes (Python) immediately.
- Post-mission: Optional auto-deletion of generated source when `ephemeral: true` and mission completes cleanly.

### 7.3 Standard `wl secret-agent` Command Interface
All service management for secret agent / ephemeral components MUST use this pattern:

- `wl secret-agent up --mission intent.json` — Launch catalog agent or specific agent type with formal mission orders.
- `wl secret-agent down --mission-id <id>` — Request graceful termination of specific mission/agent.
- `wl secret-agent status` — List all active transient agents with age, resource summary, and mission_id.
- `wl secret-agent logs --mission-id <id>` — Retrieve aether logs for the mission (if not yet purged).
- `wl secret-agent doctor` — Read-only inspection for orphans, leaked assertions, stale temps, unregistered streams. Reports only; no modification.
- `wl secret-agent repair` — Idempotent remediation: clean orphans, release leaked resources, reset to clean baseline. Safe to run repeatedly.
- `wl secret-agent catalog list [--category <name>] [--search <keyword>]` — Delegate to catalog agent to output filtered compendium entries.
- `wl secret-agent catalog briefing --mission-id <id>` — Generate human-readable mission briefing from catalog patterns relevant to the intent.

This interface guarantees Operator has uniform, auditable control over all ephemeral and secret-style components.

---

## Extension & Governance
- New patterns proposed by Operator or generated by agents are added to this compendium via Vault drop (write to `~/Wonderland/vault/ephemeral-secret-agent-catalog.md` or successor) or via `wl secret-agent catalog repair --add`.
- The Catalog Agent itself treats this file as authoritative source when `--use-vault` flag is passed.
- All additions must still satisfy the three core tenets: Recoverability, Auditability, Simplicity.

**End of Compendium — Operator has final authority on all mission parameters and extensions.**

---

*This document is itself designed to be ephemeral in spirit: it can be regenerated, filtered, or partially redacted by the Catalog Agent on demand for specific missions.*
