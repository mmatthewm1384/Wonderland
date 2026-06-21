export class Watchers {
  constructor() {
    this.items = [];
  }

  exposeFromTrajectory(trajectory, count = 6) {
    this.items = Array.from({ length: count }, (_, i) => {
      const d = 120 + i * 90;
      const p = trajectory.point(d);
      const side = (Math.random() - 0.5) * 160;
      return {
        id: `watcher_${i}`,
        x: p.x + -trajectory.vector.y * side,
        y: p.y + trajectory.vector.x * side,
        radius: 22 + Math.random() * 48,
        resonance: 0.35 + Math.random() * 0.65,
        pulse: Math.random() * Math.PI * 2,
      };
    });
  }

  update(dt) {
    for (const w of this.items) w.pulse += dt * (0.4 + w.resonance);
  }
}
