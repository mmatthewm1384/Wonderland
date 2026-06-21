export class Rings {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.items = this.seed();
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
    this.items = this.seed();
  }

  seed() {
    const cx = this.width / 2;
    const cy = this.height / 2;
    const base = Math.min(this.width, this.height);

    return [
      { scale: 0.18, ratio: 0.58, speed: 0.030, color: "green", alpha: 0.34 },
      { scale: 0.31, ratio: 0.63, speed: -0.022, color: "green", alpha: 0.26 },
      { scale: 0.48, ratio: 0.67, speed: 0.016, color: "cyan", alpha: 0.32 },
      { scale: 0.66, ratio: 0.70, speed: -0.011, color: "cyan", alpha: 0.24 },
    ].map((r, i) => ({
      id: `ring_${i}`,
      cx,
      cy,
      rx: base * r.scale,
      ry: base * r.scale * r.ratio,
      phase: Math.random() * Math.PI * 2,
      speed: r.speed,
      wobble: 0.006 + i * 0.002,
      color: r.color,
      alpha: r.alpha,
      orbiters: Array.from({ length: i < 2 ? 2 : 3 }, (_, j) => ({
        id: `${i}_${j}`,
        theta: Math.random() * Math.PI * 2,
        speed: r.speed * (1.6 + Math.random() * 0.9),
        radius: 4 + Math.random() * 5,
      })),
    }));
  }

  update(dt, trajectory) {
    for (const r of this.items) {
      r.phase += r.speed * dt;
      r.cx = this.width / 2 + trajectory.vector.x * 10;
      r.cy = this.height / 2 + trajectory.vector.y * 10;
      for (const o of r.orbiters) o.theta += o.speed * dt;
    }
  }
}
