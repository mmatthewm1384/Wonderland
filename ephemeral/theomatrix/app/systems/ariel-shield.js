export function installArielShield(bus, state, registry = null) {
  bus.on("shield-impact", event => {
    const force = event.payload.force ?? 0.1;

    state.shieldIntegrity -= force * 0.18;
    state.phase = "shield-impact";
    state.clamp();

    registry?.damage("ariel-shield", force * 0.12);
  });

  bus.on("field-ripple", event => {
    const amplitude = event.payload.amplitude ?? 0.1;

    state.shieldIntegrity -= amplitude * 0.05;
    state.coherence += 0.02;
    state.phase = "shield-ripple";
    state.clamp();

    registry?.damage("ariel-shield", amplitude * 0.04);
  });

  bus.on("pressure-bloom", event => {
    const pressure = event.payload.pressure ?? 0.1;

    state.shieldIntegrity -= pressure * 0.1;
    state.phase = "shield-pressure";
    state.clamp();

    registry?.damage("ariel-shield", pressure * 0.08);
  });

  bus.on("matrix-heal", event => {
    const amount = event.payload.amount ?? 0.1;

    state.shieldIntegrity += amount;
    state.coherence += amount * 0.5;
    state.phase = "healing";
    state.clamp();

    registry?.heal("ariel-shield", amount * 0.25);
    registry?.heal("spin-rings", amount * 0.15);
    registry?.heal("wave-field", amount * 0.1);
    registry?.heal("pressure-field", amount * 0.1);
  });
}
