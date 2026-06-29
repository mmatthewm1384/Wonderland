#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/Wonderland/ephemeral/theomatrix"
APP="$BASE/app"
BACKUP="$BASE/.backup.$(date +%Y%m%d-%H%M%S)"

[ -d "$APP" ] && mv "$APP" "$BACKUP"

mkdir -p "$APP"/{core,systems,telemetry,ui,data/events,data/snapshots,docs,scripts}

cat > "$APP/package.json" <<'JSON'
{
  "name": "theomatrix-v0.1",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "start": "node ui/dashboard.js",
    "doctor": "node scripts/doctor.js",
    "certify": "node scripts/certify.js",
    "replay": "node telemetry/replay.js"
  }
}
JSON

cat > "$APP/core/event-bus.js" <<'JS'
export class EventBus {
  constructor() {
    this.handlers = new Map();
    this.history = [];
  }

  on(type, handler) {
    if (!this.handlers.has(type)) this.handlers.set(type, []);
    this.handlers.get(type).push(handler);
  }

  emit(type, payload = {}) {
    const event = {
      id: crypto.randomUUID?.() ?? `${Date.now()}-${Math.random()}`,
      type,
      payload,
      ts: new Date().toISOString()
    };

    this.history.push(event);

    for (const handler of this.handlers.get(type) || []) {
      handler(event);
    }

    for (const handler of this.handlers.get("*") || []) {
      handler(event);
    }

    return event;
  }
}
JS

cat > "$APP/core/matrix-state.js" <<'JS'
export class MatrixState {
  constructor() {
    this.tick = 0;
    this.energy = 0.5;
    this.pressure = 0.2;
    this.coherence = 1.0;
    this.rotation = 0.0;
    this.wave = 0.0;
    this.shieldIntegrity = 1.0;
    this.phase = "stable";
  }

  clamp() {
    this.energy = Math.max(0, Math.min(1, this.energy));
    this.pressure = Math.max(0, Math.min(1, this.pressure));
    this.coherence = Math.max(0, Math.min(1, this.coherence));
    this.shieldIntegrity = Math.max(0, Math.min(1, this.shieldIntegrity));
  }

  snapshot() {
    return {
      tick: this.tick,
      energy: this.energy,
      pressure: this.pressure,
      coherence: this.coherence,
      rotation: this.rotation,
      wave: this.wave,
      shieldIntegrity: this.shieldIntegrity,
      phase: this.phase,
      ts: new Date().toISOString()
    };
  }
}
JS

cat > "$APP/systems/atom-slam.js" <<'JS'
export function installAtomSlam(bus, state) {
  bus.on("atom-slam", event => {
    const force = event.payload.force ?? 0.25;
    state.energy += force;
    state.pressure += force * 0.4;
    state.coherence -= force * 0.12;
    state.phase = "slam";
    state.clamp();
    bus.emit("shield-impact", { force });
  });
}
JS

cat > "$APP/systems/agitate-waves.js" <<'JS'
export function installAgitateWaves(bus, state) {
  bus.on("agitate-waves", event => {
    const amplitude = event.payload.amplitude ?? 0.2;
    state.wave += amplitude;
    state.coherence -= amplitude * 0.08;
    state.phase = "wave";
    state.clamp();
    bus.emit("field-ripple", { amplitude });
  });
}
JS

cat > "$APP/systems/spin-the-city.js" <<'JS'
export function installSpinTheCity(bus, state) {
  bus.on("spin-the-city", event => {
    const velocity = event.payload.velocity ?? 0.15;
    state.rotation += velocity;
    state.energy += velocity * 0.2;
    state.phase = "spin";
    state.clamp();
    bus.emit("ring-shear", { velocity });
  });
}
JS

cat > "$APP/systems/fluderation.js" <<'JS'
export function installFluderation(bus, state) {
  bus.on("fluderation", event => {
    const pressure = event.payload.pressure ?? 0.2;
    state.pressure += pressure;
    state.coherence -= pressure * 0.1;
    state.phase = "flude";
    state.clamp();
    bus.emit("pressure-bloom", { pressure });
  });
}
JS

cat > "$APP/systems/ariel-shield.js" <<'JS'
export function installArielShield(bus, state) {
  bus.on("shield-impact", event => {
    state.shieldIntegrity -= (event.payload.force ?? 0.1) * 0.18;
    state.phase = "shield-impact";
    state.clamp();
  });

  bus.on("field-ripple", event => {
    state.shieldIntegrity -= (event.payload.amplitude ?? 0.1) * 0.05;
    state.coherence += 0.02;
    state.phase = "shield-ripple";
    state.clamp();
  });

  bus.on("pressure-bloom", event => {
    state.shieldIntegrity -= (event.payload.pressure ?? 0.1) * 0.1;
    state.phase = "shield-pressure";
    state.clamp();
  });

  bus.on("matrix-heal", event => {
    const amount = event.payload.amount ?? 0.1;
    state.shieldIntegrity += amount;
    state.coherence += amount * 0.5;
    state.phase = "healing";
    state.clamp();
  });
}
JS

cat > "$APP/telemetry/recorder.js" <<'JS'
import fs from "node:fs";
import path from "node:path";

export class Recorder {
  constructor(baseDir) {
    this.baseDir = baseDir;
    this.eventsFile = path.join(baseDir, "events", "events.jsonl");
    this.timelineFile = path.join(baseDir, "events", "timeline.jsonl");
    fs.mkdirSync(path.dirname(this.eventsFile), { recursive: true });
  }

  recordEvent(event) {
    fs.appendFileSync(this.eventsFile, JSON.stringify(event) + "\n");
  }

  recordSnapshot(snapshot) {
    fs.appendFileSync(this.timelineFile, JSON.stringify(snapshot) + "\n");
  }
}
JS

cat > "$APP/telemetry/replay.js" <<'JS'
import fs from "node:fs";

const file = new URL("../data/events/events.jsonl", import.meta.url);

if (!fs.existsSync(file)) {
  console.error("No events recorded.");
  process.exit(1);
}

const lines = fs.readFileSync(file, "utf8").trim().split("\n").filter(Boolean);
for (const line of lines) console.log(JSON.stringify(JSON.parse(line), null, 2));
JS

cat > "$APP/core/simulation-loop.js" <<'JS'
export class SimulationLoop {
  constructor(bus, state, recorder) {
    this.bus = bus;
    this.state = state;
    this.recorder = recorder;
    this.running = false;
  }

  step() {
    this.state.tick += 1;

    this.state.energy *= 0.985;
    this.state.pressure *= 0.975;
    this.state.wave *= 0.96;
    this.state.coherence += (1 - this.state.coherence) * 0.01;
    this.state.shieldIntegrity += (1 - this.state.shieldIntegrity) * 0.004;

    if (this.state.energy < 0.2 && this.state.pressure < 0.2) {
      this.state.phase = "stable";
    }

    this.state.clamp();
    const snap = this.state.snapshot();
    this.recorder.recordSnapshot(snap);
    return snap;
  }
}
JS

cat > "$APP/ui/dashboard.js" <<'JS'
import readline from "node:readline";
import { EventBus } from "../core/event-bus.js";
import { MatrixState } from "../core/matrix-state.js";
import { SimulationLoop } from "../core/simulation-loop.js";
import { Recorder } from "../telemetry/recorder.js";

import { installAtomSlam } from "../systems/atom-slam.js";
import { installAgitateWaves } from "../systems/agitate-waves.js";
import { installSpinTheCity } from "../systems/spin-the-city.js";
import { installFluderation } from "../systems/fluderation.js";
import { installArielShield } from "../systems/ariel-shield.js";

const bus = new EventBus();
const state = new MatrixState();
const recorder = new Recorder(new URL("../data", import.meta.url).pathname);
const loop = new SimulationLoop(bus, state, recorder);

bus.on("*", event => recorder.recordEvent(event));

installAtomSlam(bus, state);
installAgitateWaves(bus, state);
installSpinTheCity(bus, state);
installFluderation(bus, state);
installArielShield(bus, state);

function render() {
  console.clear();
  console.log("THE∅MATRIX v0.1");
  console.log("================");
  console.log(JSON.stringify(state.snapshot(), null, 2));
  console.log("");
  console.log("Commands:");
  console.log("  slam   wave   spin   flude   heal   tick   quit");
}

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

function prompt() {
  render();
  rl.question("> ", cmd => {
    if (cmd === "quit") process.exit(0);
    if (cmd === "slam") bus.emit("atom-slam", { force: 0.35 });
    if (cmd === "wave") bus.emit("agitate-waves", { amplitude: 0.3 });
    if (cmd === "spin") bus.emit("spin-the-city", { velocity: 0.25 });
    if (cmd === "flude") bus.emit("fluderation", { pressure: 0.35 });
    if (cmd === "heal") bus.emit("matrix-heal", { amount: 0.2 });
    loop.step();
    prompt();
  });
}

prompt();
JS

cat > "$APP/scripts/doctor.js" <<'JS'
import fs from "node:fs";

const required = [
  "core/event-bus.js",
  "core/matrix-state.js",
  "core/simulation-loop.js",
  "systems/atom-slam.js",
  "systems/agitate-waves.js",
  "systems/spin-the-city.js",
  "systems/fluderation.js",
  "systems/ariel-shield.js",
  "telemetry/recorder.js",
  "ui/dashboard.js",
  "package.json"
];

let ok = true;

for (const file of required) {
  if (!fs.existsSync(new URL(`../${file}`, import.meta.url))) {
    console.error(`FAIL missing ${file}`);
    ok = false;
  } else {
    console.log(`PASS ${file}`);
  }
}

process.exit(ok ? 0 : 1);
JS

cat > "$APP/scripts/certify.js" <<'JS'
import { EventBus } from "../core/event-bus.js";
import { MatrixState } from "../core/matrix-state.js";
import { SimulationLoop } from "../core/simulation-loop.js";
import { Recorder } from "../telemetry/recorder.js";

import { installAtomSlam } from "../systems/atom-slam.js";
import { installAgitateWaves } from "../systems/agitate-waves.js";
import { installSpinTheCity } from "../systems/spin-the-city.js";
import { installFluderation } from "../systems/fluderation.js";
import { installArielShield } from "../systems/ariel-shield.js";

const bus = new EventBus();
const state = new MatrixState();
const recorder = new Recorder(new URL("../data", import.meta.url).pathname);
const loop = new SimulationLoop(bus, state, recorder);

bus.on("*", event => recorder.recordEvent(event));

installAtomSlam(bus, state);
installAgitateWaves(bus, state);
installSpinTheCity(bus, state);
installFluderation(bus, state);
installArielShield(bus, state);

bus.emit("atom-slam", { force: 0.3 });
bus.emit("agitate-waves", { amplitude: 0.2 });
bus.emit("spin-the-city", { velocity: 0.2 });
bus.emit("fluderation", { pressure: 0.2 });
bus.emit("matrix-heal", { amount: 0.1 });

for (let i = 0; i < 10; i++) loop.step();

const s = state.snapshot();

if (
  Number.isFinite(s.energy) &&
  Number.isFinite(s.pressure) &&
  Number.isFinite(s.coherence) &&
  Number.isFinite(s.shieldIntegrity) &&
  s.shieldIntegrity > 0 &&
  s.coherence > 0
) {
  console.log("PASS THEOMATRIX-v0.1-CERTIFIED");
  console.log(JSON.stringify(s, null, 2));
  process.exit(0);
}

console.error("FAIL THEOMATRIX-v0.1");
console.error(JSON.stringify(s, null, 2));
process.exit(1);
JS

cat > "$APP/docs/theomatrix-v0.1.md" <<'MD'
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
- DISABLED-Agitate Waves
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

MD

cat > "$APP/scripts/wl-theomatrix" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

APP="$HOME/Wonderland/ephemeral/theomatrix/app"

case "${1:-help}" in
start) cd "$APP" && npm start ;;
doctor) cd "$APP" && npm run doctor ;;
certify) cd "$APP" && npm run certify ;;
replay) cd "$APP" && npm run replay ;;
path) echo "$APP" ;;
*)
cat <<HELP
wl-theomatrix commands:
start
doctor
certify
replay
path
HELP
;;
esac
SH

chmod +x "$APP/scripts/wl-theomatrix"

mkdir -p "$HOME/Wonderland/bin"
ln -sf "$APP/scripts/wl-theomatrix" "$HOME/Wonderland/bin/wl-theomatrix"

echo "PASS installed THE∅MATRIX v0.1"
echo "APP=$APP"
echo "BACKUP=${BACKUP:-none}"
