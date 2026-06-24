export function installFluderation(bus, state, registry = null) {
  bus.on("fluderation", event => {
    const pressure = event.payload.pressure ?? 0.2;

    state.pressure += pressure;
    state.coherence -= pressure * 0.1;
    state.phase = "flude";
    state.clamp();

    registry?.boost("pressure-field", pressure * 0.2);
    registry?.damage("spin-rings", pressure * 0.04);
    registry?.damage("ariel-shield", pressure * 0.05);

    bus.emit("pressure-bloom", {
      source: "pressure-field",
      pressure,
      target: "ariel-shield"
    });
  });
}
