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

  seed(count = 4) {
    const marginX = this.width * 0.12;
    const marginY = this.height * 0.12;

    return Array.from({ length: count }, (_, i) => {
      const side = Math.floor(Math.random() * 4);
      let x;
      let y;

      if (side === 0) {
        x = Math.random() * this.width;
        y = marginY * Math.random();
      } else if (side === 1) {
        x = this.width - marginX * Math.random();
        y = Math.random() * this.height;
      } else if (side === 2) {
        x = Math.random() * this.width;
        y = this.height - marginY * Math.random();
      } else {
        x = marginX * Math.random();
        y = Math.random() * this.height;
      }

      return {
        id: `ghost_${i}`,
        x,
        y,
        coherence: 0.35 + Math.random() * 0.55,
        phase: Math.random() * Math.PI * 2,
      };
    });
  }

  update(dt) {
    for (const g of this.items) {
      g.phase += dt * (0.06 + g.coherence * 0.08);
    }
  }
}
