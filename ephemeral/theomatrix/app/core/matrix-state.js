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
