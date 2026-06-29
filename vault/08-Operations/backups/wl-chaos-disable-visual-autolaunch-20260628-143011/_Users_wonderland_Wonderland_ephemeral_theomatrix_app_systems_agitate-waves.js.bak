export function installAgitateWaves(bus, state, registry = null) {
  bus.on("agitate-waves", event => {
    const amplitude = event.payload.amplitude ?? 0.2;

    state.wave += amplitude;
    state.coherence -= amplitude * 0.08;
    state.phase = "wave";
    state.clamp();

    registry?.boost("wave-field", amplitude * 0.2);
    registry?.damage("ariel-shield", amplitude * 0.03);

    bus.emit("field-ripple", {
      source: "wave-field",
      amplitude,
      target: "ariel-shield"
    });
  });
}
