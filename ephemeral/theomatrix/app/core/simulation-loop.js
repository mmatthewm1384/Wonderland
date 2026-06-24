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
