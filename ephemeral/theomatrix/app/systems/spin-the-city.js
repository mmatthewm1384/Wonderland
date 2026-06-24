export function installSpinTheCity(bus, state, registry = null) {
  bus.on("spin-the-city", event => {
    const velocity = event.payload.velocity ?? 0.15;

    state.rotation += velocity;
    state.energy += velocity * 0.2;
    state.phase = "spin";
    state.clamp();

    registry?.boost("spin-rings", velocity * 0.15);

    bus.emit("ring-shear", {
      source: "spin-rings",
      velocity,
      target: "pressure-field"
    });
  });
}
