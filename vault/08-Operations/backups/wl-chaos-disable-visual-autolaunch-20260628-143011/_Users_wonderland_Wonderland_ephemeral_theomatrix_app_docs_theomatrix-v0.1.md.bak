# THE∅MATRIX v0.1

## Intent

THE∅MATRIX v0.1 converts the Matrix modules from isolated visual experiments into a coherent event-driven simulation runtime.

## Architecture

- `core/event-bus.js` routes all Matrix events.
- `core/matrix-state.js` owns canonical simulation state.
- `core/simulation-loop.js` advances decay, recovery, and temporal continuity.
- `systems/*` mutate state through event handlers.
- `telemetry/recorder.js` writes durable JSONL event and timeline records.
- `ui/dashboard.js` provides a terminal control surface.

## Systems

- Atom Slam
- Agitate Waves
- Spin The City
- Fluderation
- Ariel Shield

## Data

- `data/events/events.jsonl`
- `data/events/timeline.jsonl`
- `data/snapshots/`

## Verification

```bash
npm run doctor
npm run certify
Recovery

If the current app fails, restore latest backup:

cd ~/Wonderland/ephemeral/theomatrix
ls -d .backup.*
rm -rf app
mv .backup.YYYYMMDD-HHMMSS app
Rollback

Rollback is file-level and directory-level safe because installer moves the previous app into a timestamped backup before replacement.

Certification

Certified when:

PASS THEOMATRIX-v0.1-CERTIFIED

