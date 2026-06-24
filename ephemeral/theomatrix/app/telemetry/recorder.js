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
