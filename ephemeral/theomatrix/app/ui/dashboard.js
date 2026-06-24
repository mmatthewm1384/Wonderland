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
