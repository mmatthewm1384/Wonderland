export class AttentionDecay {
  constructor({ baseRate = 0.055, threshold = 0.2 } = {}) {
    this.value = 1.0;
    this.baseRate = baseRate;
    this.threshold = threshold;
  }

  update(dt, interest = 1.0) {
    const safeInterest = Math.max(interest, 0.1);
    const lambda = this.baseRate / safeInterest;
    this.value *= Math.exp(-lambda * dt);
    return this.value;
  }

  reset() {
    this.value = 1.0;
  }

  shouldRelease() {
    return this.value < this.threshold;
  }
}
