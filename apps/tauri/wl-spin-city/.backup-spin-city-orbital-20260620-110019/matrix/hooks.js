export const HookPhase = Object.freeze({
  IDLE: "IDLE",
  CAPTURE: "CAPTURE",
  PATH: "PATH",
  RELEASE: "RELEASE",
});

const rand = (min, max) => min + Math.random() * (max - min);

export class Hooks {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.items = [];
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
  }

  spawnFromTrajectory(trajectory, saturation = 0.5, ghostBias = 0) {
    const count = Math.max(3, Math.round(6 + saturation * 26));
    while (this.items.length < count) {
      const d = rand(-Math.min(this.width, this.height) * 0.45, Math.min(this.width, this.height) * 0.45);
      const p = trajectory.point(d);
      const side = rand(-1, 1);
      const ghostKick = Math.random() < ghostBias ? rand(-220, 220) : 0;

      this.items.push({
        id: `hook_${Date.now()}_${Math.random().toString(16).slice(2)}`,
        x: p.x + -trajectory.vector.y * side * rand(40, 220) + ghostKick,
        y: p.y + trajectory.vector.x * side * rand(40, 220) - ghostKick * 0.35,
        phase: HookPhase.IDLE,
        pulse: Math.random() * Math.PI * 2,
        age: 0,
        pathT: 0,
        path: null,
        ghostInfluenced: Math.abs(ghostKick) > 1,
      });
    }

    if (this.items.length > count) this.items.splice(0, this.items.length - count);
  }

  buildPath(hook, trajectory, interest = 0.5) {
    const length = rand(140, 260 + interest * 760);
    const bend = rand(-0.85, 0.85);
    const ex = hook.x + trajectory.vector.x * length;
    const ey = hook.y + trajectory.vector.y * length;
    const cx = hook.x + trajectory.vector.x * length * 0.45 + -trajectory.vector.y * bend * length * 0.42;
    const cy = hook.y + trajectory.vector.y * length * 0.45 + trajectory.vector.x * bend * length * 0.42;

    hook.path = { cx, cy, ex, ey };
    hook.pathT = 0;
  }

  captureNext(trajectory, attentionDecay, interest) {
    const idle = this.items.find((h) => h.phase === HookPhase.IDLE);
    if (!idle) return null;

    idle.phase = HookPhase.CAPTURE;
    this.buildPath(idle, trajectory, interest);
    attentionDecay.reset();
    return idle;
  }

  update(dt, trajectory, attentionDecay, interest) {
    for (const h of this.items) {
      h.age += dt;
      h.pulse += dt * 2.0;

      if (h.phase === HookPhase.CAPTURE) {
        h.phase = HookPhase.PATH;
      } else if (h.phase === HookPhase.PATH) {
        h.pathT += dt * (0.10 + (1 - interest) * 0.28);
        if (attentionDecay.shouldRelease() || h.pathT >= 1) {
          h.phase = HookPhase.RELEASE;
        }
      } else if (h.phase === HookPhase.RELEASE) {
        trajectory.pivot(rand(-0.32, 0.32));
        h.phase = HookPhase.IDLE;
        h.pathT = 0;
      }
    }
  }
}
