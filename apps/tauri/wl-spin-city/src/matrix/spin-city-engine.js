const WL = {
  bg: "#05070A",
  cyan: "#00E5FF",
  blue: "#3B7CFF",
  green: "#00FF66",
  purple: "#7000FF",
};

const rand = (a, b) => a + Math.random() * (b - a);
const pick = (xs) => xs[Math.floor(Math.random() * xs.length)];
const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
const marginPoint = (p, w, h, m = 70) => ({
  x: clamp(p.x, m, w - m),
  y: clamp(p.y, m, h - m),
});

function quad(p0, p1, p2, t) {
  const a = (1 - t) * (1 - t);
  const b = 2 * (1 - t) * t;
  const c = t * t;
  return {
    x: a * p0.x + b * p1.x + c * p2.x,
    y: a * p0.y + b * p1.y + c * p2.y,
  };
}

function cubic(p0, p1, p2, p3, t) {
  const a = (1 - t) ** 3;
  const b = 3 * (1 - t) ** 2 * t;
  const c = 3 * (1 - t) * t ** 2;
  const d = t ** 3;
  return {
    x: a * p0.x + b * p1.x + c * p2.x + d * p3.x,
    y: a * p0.y + b * p1.y + c * p2.y + d * p3.y,
  };
}

function cubicTangent(p0, p1, p2, p3, t) {
  return {
    x: 3 * (1 - t) ** 2 * (p1.x - p0.x) +
       6 * (1 - t) * t * (p2.x - p1.x) +
       3 * t ** 2 * (p3.x - p2.x),
    y: 3 * (1 - t) ** 2 * (p1.y - p0.y) +
       6 * (1 - t) * t * (p2.y - p1.y) +
       3 * t ** 2 * (p3.y - p2.y),
  };
}

function segmentPoint(seg, t) {
  return cubic(seg.start, seg.c1, seg.c2, seg.end, t);
}

function segmentTangent(seg, t) {
  return cubicTangent(seg.start, seg.c1, seg.c2, seg.end, t);
}

function pathHead(path) {
  if (!path.segments?.length) {
    const t = Math.max(0.025, Math.min(1, path.t));
    return {
      point: path.c1 && path.c2
        ? cubic(path.start, path.c1, path.c2, path.end, t)
        : quad(path.start, path.control, path.end, t),
      tangent: path.c1 && path.c2
        ? cubicTangent(path.start, path.c1, path.c2, path.end, t)
        : tangent(path.start, path.control, path.end, t),
    };
  }

  const total = path.segments.length;
  const scaled = Math.max(0, Math.min(total - 0.0001, path.t * total));
  const idx = Math.floor(scaled);
  const localT = scaled - idx;
  const seg = path.segments[idx];

  return {
    point: segmentPoint(seg, localT),
    tangent: segmentTangent(seg, localT),
    index: idx,
    localT,
  };
}

function tangent(p0, p1, p2, t) {
  return {
    x: 2 * (1 - t) * (p1.x - p0.x) + 2 * t * (p2.x - p1.x),
    y: 2 * (1 - t) * (p1.y - p0.y) + 2 * t * (p2.y - p1.y),
  };
}

function norm(v) {
  const d = Math.hypot(v.x, v.y) || 1;
  return { x: v.x / d, y: v.y / d };
}

export class SpinCityEngine {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.cx = width / 2;
    this.cy = height / 2;

    this.trajectory = {
      angle: -0.23,
      vector: { x: Math.cos(-0.23), y: Math.sin(-0.23) },
    };

    this.rings = [];
    this.paths = [];
    this.ghostPaths = [];
    this.lastTime = 0;
    this.nextBurstAt = 0;

    this.seedRings();
    this.spawnBurst(true);
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
    this.cx = width / 2;
    this.cy = height / 2;
    this.seedRings();
  }

  seedRings() {
    const base = Math.min(this.width, this.height);

    this.rings = [
      { s: 0.10, r: 0.50, sp:  0.085, a: 0.15, w: 0.9, c: WL.green, riders: 0 },
      { s: 0.18, r: 0.56, sp: -0.072, a: 0.36, w: 1.7, c: WL.green, riders: 2 },
      { s: 0.28, r: 0.61, sp:  0.060, a: 0.27, w: 1.1, c: WL.green, riders: 2 },
      { s: 0.40, r: 0.66, sp: -0.050, a: 0.46, w: 2.1, c: WL.cyan,  riders: 3 },
      { s: 0.53, r: 0.70, sp:  0.040, a: 0.36, w: 1.7, c: WL.cyan,  riders: 3 },
      { s: 0.65, r: 0.73, sp: -0.030, a: 0.23, w: 1.2, c: WL.cyan,  riders: 2 },
      { s: 0.75, r: 0.76, sp:  0.020, a: 0.10, w: 0.9, c: WL.cyan,  riders: 1 },
    ].map((x, i) => ({
      id: i,
      cx: this.cx,
      cy: this.cy,
      rx: base * x.s,
      ry: base * x.s * x.r,
      phase: rand(0, Math.PI * 2),
      speed: x.sp,
      alpha: x.a,
      width: x.w,
      color: x.c,
      riders: Array.from({ length: x.riders }, () => ({
        theta: rand(0, Math.PI * 2),
        speed: x.sp * rand(3.5, 5.6),
        radius: rand(4.5, 8.5),
        pulse: rand(0, Math.PI * 2),
      })),
    }));
  }

  tick(time) {
    const dt = Math.min(0.05, (time - this.lastTime) / 1000 || 0.016);
    this.lastTime = time;

    for (const r of this.rings) {
      r.phase += r.speed * dt;
      r.cx = this.cx + this.trajectory.vector.x * 8;
      r.cy = this.cy + this.trajectory.vector.y * 8;

      for (const o of r.riders) {
        o.theta += o.speed * dt;
        o.pulse += dt * 0.34;
      }
    }

    for (const p of this.paths) {
      p.t += dt * p.speed;
      p.life -= dt * p.decay;
      p.pulse += dt * 0.7;

      if (p.primary && Math.random() < 0.58) p.sparkles.push(this.makeSpark(p));
      if (!p.primary && Math.random() < 0.22) p.sparkles.push(this.makeSpark(p));

      for (const s of p.sparkles) {
        s.t += dt * s.speed;
        s.life -= dt * s.decay;
      }

      p.sparkles = p.sparkles.filter((s) => s.life > 0);
    }

    this.paths = this.paths.filter((p) => p.life > 0 && p.t < 1.12);

    for (const g of this.ghostPaths) {
      g.t += g.speed * dt;
      g.life -= g.decay * dt;
    }

    this.ghostPaths = this.ghostPaths.filter(
      (g) => g.life > 0 && g.t < g.maxProgress
    );


    if (time > this.nextBurstAt) {
      this.spawnBurst(false);
      this.nextBurstAt = time + rand(2400, 4200);
    }
  }

  pivotTrajectory(delta) {
    this.trajectory.angle += delta;
    this.trajectory.vector = {
      x: Math.cos(this.trajectory.angle),
      y: Math.sin(this.trajectory.angle),
    };
  }

  ringPoint(ring, theta) {
    const lx = Math.cos(theta) * ring.rx;
    const ly = Math.sin(theta) * ring.ry;
    const rot = ring.phase;

    return {
      x: ring.cx + lx * Math.cos(rot) - ly * Math.sin(rot),
      y: ring.cy + lx * Math.sin(rot) + ly * Math.cos(rot),
    };
  }

  makeSpark(path) {
    return {
      t: Math.max(0, path.t - rand(0.02, path.primary ? 0.28 : 0.16)),
      speed: rand(0.018, 0.052),
      life: rand(0.35, 0.85),
      decay: rand(0.35, 0.85),
      offset: rand(-13, 13),
    };
  }

  spawnBurst(initial) {
    if (initial || !this.paths.some((p) => p.primary)) {
      this.spawnPath("primary");
    }

    if (Math.random() < 0.74) this.spawnPath("minor");
    if (Math.random() < 0.48) this.spawnPath("minor");
    if (Math.random() < 0.36) this.spawnPath("ghost");

    this.pivotTrajectory(rand(-0.038, 0.038));
  }

  spawnPath(kind) {
    if (kind === "ghost") return this.spawnGhostPath();

    const primary = kind === "primary";
    const hopCount = primary ? Math.floor(rand(2, 4)) : Math.floor(rand(1, 3));

    const ringIndexes = [];
    let current = Math.floor(rand(primary ? 2 : 1, this.rings.length - 1));
    ringIndexes.push(current);

    for (let i = 0; i < hopCount; i++) {
      const dir = Math.random() < 0.58 ? 1 : -1;
      const step = Math.floor(rand(1, 3));
      current = Math.max(0, Math.min(this.rings.length - 1, current + dir * step));
      if (current === ringIndexes[ringIndexes.length - 1]) {
        current = Math.max(0, Math.min(this.rings.length - 1, current + (dir > 0 ? -1 : 1)));
      }
      ringIndexes.push(current);
    }

    const points = ringIndexes.map((ri, i) => {
      const theta = rand(0, Math.PI * 2) + i * rand(0.18, 0.55);
      return marginPoint(this.ringPoint(this.rings[ri], theta), this.width, this.height, 88);
    });

    const v = this.trajectory.vector;
    const segments = [];

    for (let i = 0; i < points.length - 1; i++) {
      const a = points[i];
      const b = points[i + 1];
      const dx = b.x - a.x;
      const dy = b.y - a.y;
      const dist = Math.hypot(dx, dy) || 1;
      const nx = -dy / dist;
      const ny = dx / dist;
      const bend = primary ? rand(-0.55, 0.55) : rand(-0.34, 0.34);
      const lift = dist * (primary ? rand(0.22, 0.48) : rand(0.14, 0.30));

      const c1 = marginPoint({
        x: a.x + dx * 0.34 + nx * bend * lift + v.x * rand(20, 90),
        y: a.y + dy * 0.34 + ny * bend * lift + v.y * rand(20, 90),
      }, this.width, this.height, 78);

      const c2 = marginPoint({
        x: a.x + dx * 0.68 - nx * bend * lift + v.x * rand(-30, 70),
        y: a.y + dy * 0.68 - ny * bend * lift + v.y * rand(-30, 70),
      }, this.width, this.height, 78);

      segments.push({
        start: a,
        c1,
        c2,
        end: b,
        fromRing: ringIndexes[i],
        toRing: ringIndexes[i + 1],
      });
    }

    

    // Ghost = unchosen transfer
    const ghostProbability = 0.07;

    if (Math.random() < ghostProbability && ringIndexes.length > 2) {

      const originRing = ringIndexes[0];
      const actualRing = ringIndexes[1];

      const candidates = [];

      for (let ri = 0; ri < this.rings.length; ri++) {
        if (ri !== originRing && ri !== actualRing) {
          candidates.push(ri);
        }
      }

      if (candidates.length) {

        const ghostRing =
          candidates[Math.floor(Math.random() * candidates.length)];

        const a =
          marginPoint(
            this.ringPoint(
              this.rings[originRing],
              rand(0, Math.PI * 2)
            ),
            this.width,
            this.height,
            88
          );

        const b =
          marginPoint(
            this.ringPoint(
              this.rings[ghostRing],
              rand(0, Math.PI * 2)
            ),
            this.width,
            this.height,
            88
          );

        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const dist = Math.hypot(dx, dy) || 1;

        const nx = -dy / dist;
        const ny = dx / dist;

        const bend = rand(-0.5,0.5);
        const lift = dist * rand(0.2,0.4);

        const c1 = {
          x: a.x + dx * 0.33 + nx * bend * lift,
          y: a.y + dy * 0.33 + ny * bend * lift
        };

        const c2 = {
          x: a.x + dx * 0.66 - nx * bend * lift,
          y: a.y + dy * 0.66 - ny * bend * lift
        };

        this.ghostPaths.push({
          start: a,
          c1,
          c2,
          end: b,
          t: 0,
          speed: 0.7,
          life: 0.45,
          decay: 0.9,

          // fades before completion
          maxProgress: rand(0.35,0.7)
        });
      }
    }

this.paths.push({
      start: points[0],
      control: segments[0].c1,
      c1: segments[0].c1,
      c2: segments[0].c2,
      end: points[points.length - 1],
      segments,
      transfers: points.slice(1, -1),
      t: 0,
      life: primary ? 1.0 : 0.78,
      decay: primary ? 0.032 : 0.064,
      speed: primary ? 0.042 : 0.024,
      pulse: 0,
      primary,
      ghost: false,
      color: primary ? WL.cyan : WL.green,
      sparkles: [],
      jump: ringIndexes,
    });
  }

  spawnGhostPath() {
    const edge = Math.floor(rand(0, 4));
    const start = {
      x: edge === 0 ? rand(0, this.width) : edge === 1 ? this.width - rand(30, 150) : edge === 2 ? rand(0, this.width) : rand(30, 150),
      y: edge === 0 ? rand(30, 150) : edge === 1 ? rand(0, this.height) : edge === 2 ? this.height - rand(30, 150) : rand(0, this.height),
    };

    const targetRing = pick(this.rings.slice(2, 6));
    const target = marginPoint(this.ringPoint(targetRing, rand(0, Math.PI * 2)), this.width, this.height, 90);

    const control = marginPoint({
      x: (start.x + target.x) / 2 + rand(-220, 220),
      y: (start.y + target.y) / 2 + rand(-170, 170),
    }, this.width, this.height, 80);

    this.paths.push({
      start,
      control,
      end: target,
      t: 0,
      life: 0.86,
      decay: 0.058,
      speed: 0.022,
      pulse: 0,
      primary: false,
      ghost: true,
      color: WL.purple,
      sparkles: [],
    });
  }

  draw(ctx) {
    ctx.fillStyle = WL.bg;
    ctx.fillRect(0, 0, this.width, this.height);

    this.drawDepthField(ctx);
    this.drawGhostPaths(ctx);
    this.drawRings(ctx);
    this.drawPaths(ctx);
  }

  drawDepthField(ctx) {
    ctx.save();
    ctx.globalAlpha = 0.055;
    ctx.strokeStyle = WL.cyan;
    ctx.lineWidth = 0.7;
    ctx.setLineDash([1, 18]);

    const base = Math.min(this.width, this.height);

    for (let i = 1; i <= 9; i++) {
      ctx.beginPath();
      ctx.ellipse(
        this.cx,
        this.cy,
        base * (0.12 + i * 0.085),
        base * (0.12 + i * 0.085) * 0.70,
        -0.18,
        0,
        Math.PI * 2
      );
      ctx.stroke();
    }

    ctx.restore();
  }

  drawRings(ctx) {
    for (const r of this.rings) {
      ctx.save();
      ctx.translate(r.cx, r.cy);
      ctx.rotate(r.phase);

      ctx.globalAlpha = r.alpha;
      ctx.strokeStyle = r.color;
      ctx.shadowColor = r.color;
      ctx.shadowBlur = 27;
      ctx.lineWidth = r.width;

      ctx.beginPath();
      ctx.ellipse(0, 0, r.rx, r.ry, 0.012 * Math.sin(r.phase), 0, Math.PI * 2);
      ctx.stroke();

      ctx.globalAlpha = r.alpha * 0.22;
      ctx.setLineDash([2, 14]);
      ctx.beginPath();
      ctx.ellipse(0, 0, r.rx * 1.036, r.ry * 1.036, 0, 0, Math.PI * 2);
      ctx.stroke();
      ctx.setLineDash([]);

      // directional ticks: makes counter-spin legible
      for (let k = 0; k < 2; k++) {
        const a = r.phase * 0.55 + k * Math.PI * 1.13;
        const x = Math.cos(a) * r.rx;
        const y = Math.sin(a) * r.ry;

        ctx.globalAlpha = r.alpha * 0.85;
        ctx.lineWidth = 1.4;
        ctx.beginPath();
        ctx.moveTo(x - 12, y - 4);
        ctx.lineTo(x, y);
        ctx.lineTo(x - 8, y + 8);
        ctx.stroke();
      }

      for (const o of r.riders) {
        const x = Math.cos(o.theta) * r.rx;
        const y = Math.sin(o.theta) * r.ry;
        const pulse = 0.5 + Math.sin(o.pulse) * 0.5;

        ctx.globalAlpha = Math.min(0.95, r.alpha + 0.34);
        ctx.shadowBlur = 34;
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(x, y, o.radius + pulse * 2.4, 0, Math.PI * 2);
        ctx.stroke();

        ctx.globalAlpha = 0.30;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.arc(x, y, (o.radius + pulse * 2.4) * 2.7, 0, Math.PI * 2);
        ctx.stroke();
      }

      ctx.restore();
    }
  }



  drawGhostPaths(ctx) {

    for (const g of this.ghostPaths) {

      const head =
        cubic(
          g.start,
          g.c1,
          g.c2,
          g.end,
          Math.min(g.t, g.maxProgress)
        );

      ctx.save();

      ctx.globalAlpha =
        0.08 * g.life;

      ctx.strokeStyle = WL.purple;
      ctx.shadowColor = WL.purple;
      ctx.shadowBlur = 8;
      ctx.lineWidth = 1;

      ctx.beginPath();
      ctx.moveTo(g.start.x, g.start.y);

      ctx.bezierCurveTo(
        g.c1.x,
        g.c1.y,
        g.c2.x,
        g.c2.y,
        head.x,
        head.y
      );

      ctx.stroke();

      ctx.restore();
    }
  }


  drawPaths(ctx) {
    // minor and ghost first, primary last
    const sorted = [...this.paths].sort((a, b) => Number(a.primary) - Number(b.primary));

    for (const p of sorted) {
      const headInfo = pathHead(p);
      const head = headInfo.point;
      const pulse = 0.5 + Math.sin(p.pulse) * 0.5;
      const tan = norm(headInfo.tangent);
      const n = { x: -tan.y, y: tan.x };

      ctx.save();

      // capture hook
      ctx.globalAlpha = p.life * (p.primary ? 0.98 : 0.62);
      ctx.strokeStyle = p.ghost ? WL.purple : WL.green;
      ctx.shadowColor = ctx.strokeStyle;
      ctx.shadowBlur = p.primary ? 42 : 26;
      ctx.lineWidth = p.primary ? 3.2 : 1.8;
      ctx.beginPath();
      ctx.arc(p.start.x, p.start.y, (p.primary ? 11 : 6) + pulse * 6, 0, Math.PI * 2);
      ctx.stroke();

      // transfer hooks between rings
      if (p.transfers?.length) {
        for (const [i, tp] of p.transfers.entries()) {
          const reveal = p.t * p.segments.length > i + 0.75 ? 1 : 0.28;
          ctx.globalAlpha = p.life * reveal * (p.primary ? 0.58 : 0.30);
          ctx.strokeStyle = WL.green;
          ctx.shadowColor = WL.green;
          ctx.shadowBlur = 22;
          ctx.lineWidth = p.primary ? 1.8 : 1.1;
          ctx.beginPath();
          ctx.arc(tp.x, tp.y, 5 + pulse * 3, 0, Math.PI * 2);
          ctx.stroke();
        }
      }

      // faint complete route
      ctx.globalAlpha = p.life * (p.primary ? 0.16 : 0.08);
      ctx.strokeStyle = p.color;
      ctx.shadowColor = p.color;
      ctx.shadowBlur = 12;
      ctx.lineWidth = p.primary ? 1.2 : 0.9;
      for (const seg of p.segments || []) {
        ctx.beginPath();
        ctx.moveTo(seg.start.x, seg.start.y);
        ctx.bezierCurveTo(seg.c1.x, seg.c1.y, seg.c2.x, seg.c2.y, seg.end.x, seg.end.y);
        ctx.stroke();
      }

      // traveled route: draw completed segments plus partial active segment
      const total = p.segments?.length || 1;
      const scaled = Math.max(0, Math.min(total, p.t * total));
      const activeIdx = Math.floor(Math.min(total - 1, scaled));
      const localT = scaled - activeIdx;

      for (let i = 0; i < total; i++) {
        const seg = p.segments[i];
        if (!seg) continue;

        let endPoint = seg.end;
        let draw = i < activeIdx;

        if (i === activeIdx) {
          endPoint = segmentPoint(seg, Math.max(0.03, Math.min(1, localT)));
          draw = true;
        }

        if (!draw) continue;

        ctx.globalAlpha = p.life * (p.primary ? 0.30 : 0.14);
        ctx.strokeStyle = p.color;
        ctx.shadowColor = p.color;
        ctx.shadowBlur = p.primary ? 54 : 28;
        ctx.lineWidth = p.primary ? 9.5 : 4.0;
        ctx.beginPath();
        ctx.moveTo(seg.start.x, seg.start.y);
        ctx.bezierCurveTo(seg.c1.x, seg.c1.y, seg.c2.x, seg.c2.y, endPoint.x, endPoint.y);
        ctx.stroke();

        ctx.globalAlpha = p.life * (p.primary ? 1.0 : 0.58);
        ctx.shadowBlur = p.primary ? 38 : 22;
        ctx.lineWidth = p.primary ? 3.5 : 1.9;
        ctx.beginPath();
        ctx.moveTo(seg.start.x, seg.start.y);
        ctx.bezierCurveTo(seg.c1.x, seg.c1.y, seg.c2.x, seg.c2.y, endPoint.x, endPoint.y);
        ctx.stroke();
      }

      // spark trail along entire multi-hop journey
      for (const s of p.sparkles) {
        const st = Math.max(0, Math.min(0.999, s.t));
        const scaledSpark = st * total;
        const si = Math.floor(scaledSpark);
        const lt = scaledSpark - si;
        const seg = p.segments?.[si];
        if (!seg) continue;
        const q = segmentPoint(seg, lt);

        ctx.globalAlpha = p.life * s.life * (p.primary ? 0.75 : 0.38);
        ctx.fillStyle = p.color;
        ctx.shadowColor = p.color;
        ctx.shadowBlur = 16;
        ctx.beginPath();
        ctx.arc(q.x + n.x * s.offset, q.y + n.y * s.offset, p.primary ? 1.55 : 1.0, 0, Math.PI * 2);
        ctx.fill();
      }

      // release arrow
      ctx.globalAlpha = p.life * 0.98;
      ctx.strokeStyle = p.primary ? WL.green : p.color;
      ctx.shadowColor = ctx.strokeStyle;
      ctx.shadowBlur = 26;
      ctx.lineWidth = p.primary ? 2.4 : 1.4;

      const size = p.primary ? 15 : 10;
      ctx.beginPath();
      ctx.moveTo(head.x - tan.x * size + n.x * 5, head.y - tan.y * size + n.y * 5);
      ctx.lineTo(head.x, head.y);
      ctx.lineTo(head.x - tan.x * size - n.x * 5, head.y - tan.y * size - n.y * 5);
      ctx.stroke();

      // active head halo
      if (p.primary) {
        ctx.globalAlpha = p.life * 0.72;
        ctx.strokeStyle = WL.cyan;
        ctx.shadowColor = WL.cyan;
        ctx.shadowBlur = 36;
        ctx.lineWidth = 2.2;
        ctx.beginPath();
        ctx.arc(head.x, head.y, 8 + pulse * 5, 0, Math.PI * 2);
        ctx.stroke();
      }

      ctx.restore();
    }
  }
}
