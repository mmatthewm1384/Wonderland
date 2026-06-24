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
