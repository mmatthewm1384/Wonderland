# FSEvent Monitoring Tools Exploration — Wonderland Component

**Classification:** OPERATOR EYES ONLY  
**Date:** 2026-06-22

## Purpose
Exploration, comparison, and production-ready integration blueprint for FSEvent monitoring on macOS, optimized for Wonderland's FSEvent-based apps (slam_to_ground series), ephemeral/secret-agent patterns, Zero-Trust posture, intent-driven workflows, graceful shutdown, and 60s timeouts.

## Files
- `fsevent-monitoring-exploration-report.md` — Comprehensive report with comparison table, API details, best practices, and complete Swift `FSEventMissionMonitor` example.
- `README.md` — This file.

## Quick Start
1. Read the report (especially sections 2, 4, and 5).
2. Copy `FSEventMissionMonitor.swift` (the example class from the report) into your FSEvent app target.
3. Extend your existing `SlamError` enum with the new cases.
4. Wire the monitor into your intent-driven launch path + ZT PEP.
5. Test graceful shutdown (signals, timeout, explicit stop).

## Integration with Wonderland Ecosystem
- Primary recommendation: FSEventStream for broad monitoring; supplement with kqueue/DispatchSource only for specific granularity needs.
- Aligns with: Ephemeral Catalog, Zero-Trust Report (PEP before stream create), Chat Architecture Map, wl CLI patterns, aether logging, visual effect triggering.
- Future: `wl fsevent-monitor` shim + auto-drop of this report to vault.

## Verification
- Compile the Swift example in your macOS project (swiftc or Xcode).
- Run with sample intent JSON containing `watch_paths` and `mission_id`.
- Verify: stream starts, events delivered, clean stop on signal/timeout/deinit, no orphan streams (check via `lsof` or Activity Monitor).

## Recovery
- Old streams: Invalidate + Release manually or via enhanced `wl ... doctor/repair`.
- Rollback of this exploration: Remove the directory; no persistent state.

This gives you battle-tested patterns to make your FSEvent apps robust, recoverable, and aligned with all Wonderland engineering principles.

**Operator has final authority.**
