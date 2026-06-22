
async function wlNativeReadChaosContract() {
  try {
    if (window.__TAURI__?.core?.invoke) {
      return await window.__TAURI__.core.invoke("read_chaos_contract");
    }
  } catch {}

  try {
    const mod = await import("@tauri-apps/api/core");
    return await mod.invoke("read_chaos_contract");
  } catch {}

  return null;
}


// WL_CHAOS_DROP_IN_SPIN_RINGS
async function wlLoadChaosContract() {
  try {
    const native = await wlNativeReadChaosContract();
    if (native) return JSON.parse(native);
  } catch {}

  try {
    const response = await fetch("file:///Users/wonderland/Wonderland/vault/chaos/visual-chaos-contract.json?t=" + Date.now(), { cache: "no-store" });
    return await response.json();
  } catch {
    return null;
  }
}

export class Rings {
  constructor(width, height) {
    this.width = width;
    this.height = height;
    this.chaos = null;
    this.wlLastContract = "";
    this.items = this.seed();
    this.reloadChaos();
    this.reloadChaos();
  }

  resize(width, height) {
    this.width = width;
    this.height = height;
    this.items = this.seed();
  }


  // WL_PHASE_D1_SPIN_CITY_LIVE_APPLY
  async reloadChaos() {
    const contract = await wlLoadChaosContract();
    const serialized = JSON.stringify(contract ?? {});

    if (serialized === this.wlLastContract) {
      return;
    }

    this.wlLastContract = serialized;
    this.chaos = contract?.chaos_active ? contract?.apps?.["wl-spin-city"] : null;
    this.items = this.seed();
  }

  seed() {
    const cx = this.width / 2;
    const cy = this.height / 2;
    const base = Math.min(this.width, this.height);

    
    const chaos = this.chaos;
    const ringCount = chaos?.rings ?? 5;
    const speedBoost = chaos?.rotation_speed ?? 1.0;
    const jitterBoost = chaos?.jitter ?? 0.35;

    const baseRings = [
      { scale: 0.165, ratio: 0.54, speed:  0.010, color: "green", alpha: 0.34, width: 1.7, riders: 1 },
      { scale: 0.290, ratio: 0.61, speed: -0.008, color: "green", alpha: 0.28, width: 1.5, riders: 2 },
      { scale: 0.470, ratio: 0.66, speed:  0.006, color: "cyan",  alpha: 0.35, width: 1.8, riders: 2 },
      { scale: 0.650, ratio: 0.70, speed: -0.004, color: "cyan",  alpha: 0.28, width: 1.5, riders: 2 },
      { scale: 0.805, ratio: 0.72, speed:  0.003, color: "cyan",  alpha: 0.16, width: 1.1, riders: 1 },
    ];

    return baseRings.slice(0, ringCount).map((r, i) => ({

      id: `ring_${i}`,
      cx,
      cy,
      rx: base * r.scale,
      ry: base * r.scale * r.ratio,
      phase: Math.random() * Math.PI * 2,
      speed: r.speed * speedBoost,
      color: r.color,
      alpha: r.alpha,
      width: r.width,
      wobble: (0.002 + i * 0.0015) * (1 + jitterBoost),
      riders: Array.from({ length: r.riders }, (_, j) => ({
        id: `${i}_${j}`,
        theta: Math.random() * Math.PI * 2,
        speed: r.speed * speedBoost * (1.5 + Math.random() * 0.7),
        radius: 4.5 + Math.random() * 3.5,
        pulse: Math.random() * Math.PI * 2,
      })),
    }));
  }

  update(dt, trajectory) {
    for (const r of this.items) {
      r.phase += r.speed * dt;
      r.cx = this.width / 2 + trajectory.vector.x * 8;
      r.cy = this.height / 2 + trajectory.vector.y * 8;

      for (const rider of r.riders) {
        rider.theta += rider.speed * dt;
        rider.pulse += dt * 0.45;
      }
    }
  }
}
