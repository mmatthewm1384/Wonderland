export function installAtomSlam(bus, state, registry = null) {
  bus.on("atom-slam", event => {
    const force = event.payload.force ?? 0.25;

    state.energy += force;
    state.pressure += force * 0.4;
    state.coherence -= force * 0.12;
    state.phase = "slam";
    state.clamp();

    registry?.boost("atom-core", force * 0.2);
    registry?.damage("ariel-shield", force * 0.08);
    registry?.damage("spin-rings", force * 0.04);

    bus.emit("shockwave", {
      source: "atom-core",
      force,
      target: "ariel-shield"
    });

    bus.emit("shield-impact", { force });
  });
}
