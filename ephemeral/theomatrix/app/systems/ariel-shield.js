export function installArielShield(bus, state) {
  bus.on("shield-impact", event => {
    state.shieldIntegrity -= (event.payload.force ?? 0.1) * 0.18;
    state.phase = "shield-impact";
    state.clamp();
  });

  bus.on("field-ripple", event => {
    state.shieldIntegrity -= (event.payload.amplitude ?? 0.1) * 0.05;
    state.coherence += 0.02;
    state.phase = "shield-ripple";
    state.clamp();
  });

  bus.on("pressure-bloom", event => {
    state.shieldIntegrity -= (event.payload.pressure ?? 0.1) * 0.1;
    state.phase = "shield-pressure";
    state.clamp();
  });

  bus.on("matrix-heal", event => {
    const amount = event.payload.amount ?? 0.1;
    state.shieldIntegrity += amount;
    state.coherence += amount * 0.5;
    state.phase = "healing";
    state.clamp();
  });
}
