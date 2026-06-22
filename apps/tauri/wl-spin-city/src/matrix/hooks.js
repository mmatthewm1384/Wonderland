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

  spawnFromRings(rings, saturation = 0.18, ghostBias = 0.08) {
    const target = Math.max(3, Math.round(3 + saturation * 7));

    while (this.items.length < target) {
      const ring = rings.items[Math.floor(Math.random() * rings.items.length)];
      const theta = Math.random() * Math.PI * 2;
      const cos = Math.cos(theta);
      const sin = Math.sin(theta);

      const localX = cos * ring.rx;
      const localY = sin * ring.ry;

      const rot = ring.phase;
      const x = ring.cx + localX * Math.cos(rot) - localY * Math.sin(rot);
      const y = ring.cy + localX * Math.sin(rot) + localY * Math.cos(rot);

      const ghost = Math.random() < ghostBias;

      this.items.push({
        id: `hook_${Date.now()}_${Math.random().toString(16).slice(2)}`,
        x: ghost ? x + rand(-160, 160) : x,
        y: ghost ? y + rand(-120, 120) : y,
        phase: HookPhase.IDLE,
        pulse: Math.random() * Math.PI * 2,
        age: 0,
        pathT: 0,
        path: null,
        ghostInfluenced: ghost,
      });
    }

    if (this.items.length > target) {
      this.items.splice(0, this.items.length - target);
    }
  }

  buildPath(hook, trajectory, interest = 0.72) {
    const length = rand(210, 360 + interest * 520);
    const bend = rand(-0.52, 0.52);

    const ex = hook.x + trajectory.vector.x * length;
    const ey = hook.y + trajectory.vector.y * length;

    const cx =
      hook.x +
      trajectory.vector.x * length * 0.48 +
      -trajectory.vector.y * bend * length * 0.42;

    const cy =
      hook.y +
      trajectory.vector.y * length * 0.48 +
      trajectory.vector.x * bend * length * 0.42;

    hook.path = { sx: hook.x, sy: hook.y, cx, cy, ex, ey };
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

  update(dt, trajectory, attentionDecay, interest, echoes) {
    for (const h of this.items) {
      h.age += dt;
      h.pulse += dt * 0.55;

      if (h.phase === HookPhase.CAPTURE) {
        h.phase = HookPhase.PATH;
      } else if (h.phase === HookPhase.PATH) {
        h.pathT += dt * (0.020 + (1 - interest) * 0.060);

        if (attentionDecay.shouldRelease() || h.pathT >= 1) {
          h.phase = HookPhase.RELEASE;
          if (echoes && h.path) echoes.add(h.path, h.ghostInfluenced);
        }
      } else if (h.phase === HookPhase.RELEASE) {
        trajectory.pivot(rand(-0.10, 0.10));
        h.phase = HookPhase.IDLE;
        h.pathT = 0;
      }
    }
  }
}
