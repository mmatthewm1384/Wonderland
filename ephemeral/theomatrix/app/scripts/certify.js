import { EventBus } from "../core/event-bus.js";
import { MatrixState } from "../core/matrix-state.js";
import { EntityRegistry, seedMatrixEntities } from "../core/entity-registry.js";
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
const registry = new EntityRegistry();
seedMatrixEntities(registry);
const loop = new SimulationLoop(bus, state, recorder);

bus.on("*", event => recorder.recordEvent(event));

installAtomSlam(bus, state, registry);
installAgitateWaves(bus, state, registry);
installSpinTheCity(bus, state, registry);
installFluderation(bus, state, registry);
installArielShield(bus, state, registry);

bus.emit("atom-slam", { force: 0.3 });
bus.emit("agitate-waves", { amplitude: 0.2 });
bus.emit("spin-the-city", { velocity: 0.2 });
bus.emit("fluderation", { pressure: 0.2 });
bus.emit("matrix-heal", { amount: 0.1 });

for (let i = 0; i < 10; i++) loop.step();

const s = state.snapshot();
const entities = registry.snapshot();
const requiredEntities = ["atom-core", "ariel-shield", "spin-rings", "wave-field", "pressure-field"];

if (
  Number.isFinite(s.energy) &&
  Number.isFinite(s.pressure) &&
  Number.isFinite(s.coherence) &&
  Number.isFinite(s.shieldIntegrity) &&
  s.shieldIntegrity > 0 &&
  s.coherence > 0 &&
  requiredEntities.every(id => entities.some(e => e.id === id))
) {
  console.log("PASS THEOMATRIX-v0.1-CERTIFIED");
  console.log(JSON.stringify({ state: s, entities }, null, 2));
  process.exit(0);
}

console.error("FAIL THEOMATRIX-v0.1");
console.error(JSON.stringify({ state: s, entities }, null, 2));
process.exit(1);
