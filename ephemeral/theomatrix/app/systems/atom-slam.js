export function installAtomSlam(bus, state) {
  bus.on("atom-slam", event => {
    const force = event.payload.force ?? 0.25;
    state.energy += force;
    state.pressure += force * 0.4;
    state.coherence -= force * 0.12;
    state.phase = "slam";
    state.clamp();
    bus.emit("shield-impact", { force });
  });
}
