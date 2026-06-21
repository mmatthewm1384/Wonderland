import { WL_PALETTE } from "./ontology.js";
import { AttentionDecay } from "./attention-decay.js";
import { Trajectory } from "./trajectory.js";
import { Rings } from "./rings.js";
import { Hooks, HookPhase } from "./hooks.js";
import { Watchers } from "./watchers.js";
import { Ghosts } from "./ghosts.js";
import { Echoes } from "./echoes.js";
import { Collapse } from "./collapse.js";

export class SpinCityEngine {
  constructor(width, height) {
    this.width = width;
    this.height = height;

    this.state = {
      saturation: 0.46,
      interest: 0.58,
      attention: 0.42,
      watcherPressure: 0.46,
      ghostPressure: 0.22,
    };

    this.attentionDecay = new AttentionDecay({ baseRate: 0.28, threshold: 0.2 });
    this.trajectory = new Trajectory(width, height);
    this.rings = new Rings(width, height);
    this.hooks = new Hooks(width, height);
    this.watchers = new Watchers();
    this.ghosts = new Ghosts(width, height);
    this.echoes = new Echoes();
    this.collapse = new Collapse();

    this.nextCapture = 0;
    this.lastTime = 0;
    this.watchers.exposeFromTrajectory(this.trajectory, 7);
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
    this.trajectory.resize(width, height);
    this.rings.resize(width, height);
    this.hooks.resize(width, height);
    this.ghosts.resize(width, height);
  }

  tick(time) {
    const dt = Math.min(0.05, (time - this.lastTime) / 1000 || 0.016);
    this.lastTime = time;

    this.attentionDecay.update(dt, this.state.interest);
    this.rings.update(dt, this.trajectory);
    this.ghosts.update(dt);
    this.echoes.update(dt);
    this.watchers.update(dt);
    this.collapse.update(dt);

    this.hooks.spawnFromTrajectory(this.trajectory, this.state.saturation, this.state.ghostPressure);
    this.hooks.update(dt, this.trajectory, this.attentionDecay, this.state.interest);

    const delay = 2200 - this.state.attention * 1700;
    if (time > this.nextCapture) {
      const captured = this.hooks.captureNext(this.trajectory, this.attentionDecay, this.state.interest);
      if (captured?.path) this.echoes.add(captured.path, captured.ghostInfluenced);
      this.watchers.exposeFromTrajectory(this.trajectory, Math.round(4 + this.state.watcherPressure * 10));
      this.nextCapture = time + delay * (0.45 + Math.random());
    }

    this.collapse.maybeTrigger(this.watchers, this.state.interest);
  }

  draw(ctx) {
    ctx.fillStyle = WL_PALETTE.background;
    ctx.fillRect(0, 0, this.width, this.height);
    this.drawGhosts(ctx);
    this.drawEchoes(ctx);
    this.drawRings(ctx);
    this.drawWatchers(ctx);
    this.drawHooks(ctx);
    this.drawCollapse(ctx);
    // trajectory is causal/invisible; do not render it
    // this.drawTrajectory(ctx);
  }

  drawRings(ctx) {
    for (const r of this.rings.items) {
      ctx.save();
      ctx.translate(r.cx, r.cy);
      ctx.rotate(r.phase);
      ctx.globalAlpha = 0.11;
      ctx.strokeStyle = WL_PALETTE.cyan;
      ctx.shadowColor = WL_PALETTE.cyan;
      ctx.shadowBlur = 15;
      ctx.lineWidth = 1.4;
      ctx.beginPath();
      ctx.ellipse(0, 0, r.rx, r.ry, Math.sin(r.phase) * r.wobble * 10, 0, Math.PI * 2);
      ctx.stroke();
      ctx.restore();
    }
  }

  drawHooks(ctx) {
    for (const h of this.hooks.items) {
      const p = 0.5 + Math.sin(h.pulse) * 0.5;
      ctx.save();
      ctx.globalAlpha = h.phase === HookPhase.PATH ? 1.0 : 0.72;
      ctx.strokeStyle = h.ghostInfluenced ? WL_PALETTE.purple : WL_PALETTE.green;
      ctx.shadowColor = ctx.strokeStyle;
      ctx.shadowBlur = 18;
      ctx.lineWidth = h.phase === HookPhase.PATH ? 2.6 : 1.8;
      ctx.beginPath();
      ctx.arc(h.x, h.y, 4 + p * 8, 0, Math.PI * 2);
      ctx.stroke();

      if (h.path) {
        ctx.strokeStyle = h.ghostInfluenced ? WL_PALETTE.purple : WL_PALETTE.cyan;
        ctx.globalAlpha = 0.65;
        ctx.beginPath();
        ctx.moveTo(h.x, h.y);
        ctx.quadraticCurveTo(h.path.cx, h.path.cy, h.path.ex, h.path.ey);
        ctx.stroke();
      }
      ctx.restore();
    }
  }

  drawWatchers(ctx) {
    for (const w of this.watchers.items) {
      ctx.save();
      ctx.globalAlpha = 0.08 + w.resonance * 0.14;
      ctx.strokeStyle = WL_PALETTE.green;
      ctx.shadowColor = WL_PALETTE.green;
      ctx.shadowBlur = 12;
      ctx.setLineDash([2, 18]);
      ctx.beginPath();
      ctx.arc(w.x, w.y, w.radius + Math.sin(w.pulse) * 4, 0, Math.PI * 2);
      ctx.stroke();
      ctx.restore();
    }
  }

  drawGhosts(ctx) {
    for (const g of this.ghosts.items) {
      ctx.save();
      ctx.globalAlpha = 0.045 + g.coherence * 0.08;
      ctx.strokeStyle = WL_PALETTE.purple;
      ctx.shadowColor = WL_PALETTE.purple;
      ctx.shadowBlur = 22;
      ctx.setLineDash([2, 15]);
      ctx.beginPath();
      ctx.arc(g.x + Math.sin(g.phase) * 18, g.y + Math.cos(g.phase) * 18, 18 + g.coherence * 34, 0, Math.PI * 2);
      ctx.stroke();
      ctx.restore();
    }
  }

  drawEchoes(ctx) {
    for (const e of this.echoes.items) {
      ctx.save();
      ctx.globalAlpha = e.life * 0.28;
      ctx.strokeStyle = e.ghostInfluenced ? WL_PALETTE.purple : WL_PALETTE.cyan;
      ctx.shadowColor = ctx.strokeStyle;
      ctx.shadowBlur = 10;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(e.cx, e.cy);
      ctx.quadraticCurveTo(e.cx, e.cy, e.ex, e.ey);
      ctx.stroke();
      ctx.restore();
    }
  }

  drawCollapse(ctx) {
    for (const c of this.collapse.events) {
      ctx.save();
      ctx.globalAlpha = c.life;
      ctx.strokeStyle = WL_PALETTE.green;
      ctx.shadowColor = WL_PALETTE.green;
      ctx.shadowBlur = 28;
      for (let i = 0; i < c.arms; i++) {
        const a = (Math.PI * 2 * i) / c.arms;
        ctx.beginPath();
        ctx.moveTo(c.x, c.y);
        ctx.lineTo(c.x + Math.cos(a) * 80 * c.life, c.y + Math.sin(a) * 80 * c.life);
        ctx.stroke();
      }
      ctx.restore();
    }
  }

  drawTrajectory(ctx) {
    ctx.save();
    ctx.globalAlpha = 0.22;
    ctx.strokeStyle = WL_PALETTE.green;
    ctx.setLineDash([10, 20]);
    ctx.beginPath();
    const a = this.trajectory.point(-1000);
    const b = this.trajectory.point(1000);
    ctx.moveTo(a.x, a.y);
    ctx.lineTo(b.x, b.y);
    ctx.stroke();
    ctx.restore();
  }
}
