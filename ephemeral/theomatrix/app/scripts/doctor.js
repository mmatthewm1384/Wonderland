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
