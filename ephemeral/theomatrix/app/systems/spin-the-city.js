export function installSpinTheCity(bus, state) {
  bus.on("spin-the-city", event => {
    const velocity = event.payload.velocity ?? 0.15;
    state.rotation += velocity;
    state.energy += velocity * 0.2;
    state.phase = "spin";
    state.clamp();
    bus.emit("ring-shear", { velocity });
  });
}
