import fs from "node:fs";

const file = new URL("../data/events/events.jsonl", import.meta.url);

if (!fs.existsSync(file)) {
  console.error("No events recorded.");
  process.exit(1);
}

const lines = fs.readFileSync(file, "utf8").trim().split("\n").filter(Boolean);
for (const line of lines) console.log(JSON.stringify(JSON.parse(line), null, 2));
