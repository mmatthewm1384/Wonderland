export class Echoes {
  constructor() {
    this.items = [];
  }

  add(path, ghostInfluenced = false) {
    if (!path) return;

    this.items.push({
      ...path,
      ghostInfluenced,
      life: 1.0,
    });

    if (this.items.length > 20) this.items.shift();
  }

  update(dt) {
    for (const e of this.items) {
      e.life -= dt * 0.055;
    }

    this.items = this.items.filter((e) => e.life > 0);
  }
}
