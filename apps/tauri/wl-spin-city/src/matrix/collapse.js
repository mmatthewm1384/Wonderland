export class Collapse {
  constructor() {
    this.events = [];
  }

  maybeTrigger(watchers, interest) {
    const chain = watchers.items.filter((w) => w.resonance > 0.82);
    if (interest > 0.8 && chain.length >= 2 && Math.random() < 0.003) {
      const seed = chain[Math.floor(Math.random() * chain.length)];
      this.events.push({
        x: seed.x,
        y: seed.y,
        life: 1,
        arms: 4 + Math.floor(Math.random() * 5),
      });
    }
  }

  update(dt) {
    for (const e of this.events) {
      e.life -= dt * 0.18;
    }

    this.events = this.events.filter((e) => e.life > 0);
  }
}
