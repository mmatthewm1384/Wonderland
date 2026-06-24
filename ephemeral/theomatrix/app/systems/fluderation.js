export function installFluderation(bus, state) {
  bus.on("fluderation", event => {
    const pressure = event.payload.pressure ?? 0.2;
    state.pressure += pressure;
    state.coherence -= pressure * 0.1;
    state.phase = "flude";
    state.clamp();
    bus.emit("pressure-bloom", { pressure });
  });
}
