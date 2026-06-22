export class Watchers {
  constructor() {
    this.items = [];
  }

  exposeFromTrajectory(trajectory, count = 4) {
    this.items = Array.from({ length: count }, (_, i) => {
      const d = 130 + i * 120;
      const p = trajectory.point(d);
      const side = (Math.random() - 0.5) * 190;
      return {
        id: `watcher_${i}`,
        x: p.x + -trajectory.vector.y * side,
        y: p.y + trajectory.vector.x * side,
        radius: 28 + Math.random() * 58,
        resonance: 0.35 + Math.random() * 0.65,
        pulse: Math.random() * Math.PI * 2,
      };
    });
  }

  update(dt) {
    for (const w of this.items) {
      w.pulse += dt * (0.18 + w.resonance * 0.25);
    }
  }
}
