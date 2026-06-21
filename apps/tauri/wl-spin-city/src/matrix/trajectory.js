export class Trajectory {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.angle = -Math.PI / 8;
    this.origin = { x: width / 2, y: height / 2 };
    this.vector = { x: Math.cos(this.angle), y: Math.sin(this.angle) };
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
    this.origin = { x: width / 2, y: height / 2 };
  }

  pivot(amount) {
    this.angle += amount;
    this.vector = { x: Math.cos(this.angle), y: Math.sin(this.angle) };
  }

  point(distance) {
    return {
      x: this.origin.x + this.vector.x * distance,
      y: this.origin.y + this.vector.y * distance,
    };
  }
}
