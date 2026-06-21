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
    return [0.22, 0.34, 0.48, 0.64].map((scale, i) => ({
      id: `ring_${i}`,
      cx,
      cy,
      rx: base * scale,
      ry: base * scale * (0.62 + i * 0.07),
      phase: Math.random() * Math.PI * 2,
      speed: (i % 2 === 0 ? 1 : -1) * (0.08 + i * 0.035),
      wobble: 0.018 + i * 0.009,
    }));
  }

  update(dt, trajectory) {
    for (const r of this.items) {
      r.phase += r.speed * dt;
      r.cx = this.width / 2 + trajectory.vector.x * 18;
      r.cy = this.height / 2 + trajectory.vector.y * 18;
    }
  }
}
