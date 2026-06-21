export class Ghosts {
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

  seed(count = 10) {
    return Array.from({ length: count }, (_, i) => ({
      id: `ghost_${i}`,
      x: Math.random() * this.width,
      y: Math.random() * this.height,
      coherence: 0.25 + Math.random() * 0.7,
      phase: Math.random() * Math.PI * 2,
    }));
  }

  update(dt) {
    for (const g of this.items) g.phase += dt * (0.15 + g.coherence * 0.4);
  }
}
