const canvas = document.getElementById("spin-city");
const ctx = canvas.getContext("2d");

const cursor = {
  x: 0,
  y: 0,
  active: false,
  lastMove: 0
};

window.addEventListener("mousemove", event => {
  cursor.x = event.clientX;
  cursor.y = event.clientY;
  cursor.active = true;
  cursor.lastMove = performance.now() * 0.001;
});

window.addEventListener("mouseleave", () => {
  cursor.active = false;
});
const panel = document.getElementById("panel");
const presetName = document.getElementById("presetName");

let w = 0;
let h = 0;
let dpr = 1;

const colors = ["#00E5FF", "#7000FF", "#00FF66"];

const ghostFragments = Array.from({ length: 28 }, (_, i) => ({
  seed: i * 41.73,
  born: Math.random() * 20,
  life: 8 + Math.random() * 14,
  radius: 80 + Math.random() * 360,
  angle: Math.random() * Math.PI * 2,
  spin: -0.08 + Math.random() * 0.16,
  curl: 0.25 + Math.random() * 0.8,
  color: colors[i % colors.length]
}));

const settings = {
  speed: 0.28,
  hooks: 44,
  dots: 5,
  glow: 0.82,
  fade: 0.12,
  curl: 1.24,
  depth: 1.05,
  pull: 1.2
};

const presets = {
  hypnotic: { speed: 0.22, hooks: 38, dots: 4, glow: 0.66, fade: 0.10, curl: 1.16, depth: 0.9, pull: 1.0 },
  haunted: { speed: 0.16, hooks: 50, dots: 5, glow: 0.92, fade: 0.07, curl: 1.68, depth: 1.25, pull: 1.45 },
  storm: { speed: 0.58, hooks: 70, dots: 7, glow: 1.1, fade: 0.16, curl: 0.92, depth: 1.1, pull: 1.0 },
  singularity: { speed: 0.31, hooks: 84, dots: 9, glow: 1.28, fade: 0.06, curl: 1.86, depth: 1.45, pull: 1.95 },
  abyss: { speed: 0.12, hooks: 58, dots: 3, glow: 0.54, fade: 0.045, curl: 2.05, depth: 1.7, pull: 2.15 },
  wonderland: { speed: 0.24, hooks: 58, dots: 6, glow: 0.88, fade: 0.08, curl: 1.58, depth: 1.40, pull: 1.95 },
  oracle: { speed: 0.11, hooks: 34, dots: 3, glow: 0.62, fade: 0.04, curl: 2.10, depth: 1.75, pull: 2.30 }
};

let screensaver = false;
let productionMode = false;
let lastPresetCycle = 0;
let activePresetIndex = 0;
const cyclePresets = ["hypnotic", "haunted", "wonderland", "oracle", "singularity"];

function syncControls() {
  for (const key of Object.keys(settings)) {
    const input = document.getElementById(key);
    const val = document.getElementById(`${key}Val`);
    if (input) input.value = String(settings[key]);
    if (val) val.textContent = String(settings[key]);
  }
}

function saveSettings(name = "custom") {
  localStorage.setItem("wl-spin-city-settings", JSON.stringify({ name, settings }));
}

function loadSettings() {
  try {
    const raw = localStorage.getItem("wl-spin-city-settings");
    if (!raw) return;
    const saved = JSON.parse(raw);
    Object.assign(settings, saved.settings || {});
    presetName.textContent = `MODE: ${saved.name || "custom"}`;
    syncControls();
  } catch {}
}

function applyPreset(name) {
  const preset = presets[name];
  if (!preset) return;
  Object.assign(settings, preset);
  presetName.textContent = `MODE: ${name}`;
  syncControls();
  saveSettings(name);
}

function randomize() {
  settings.speed = +(0.1 + Math.random() * 0.55).toFixed(2);
  settings.hooks = Math.floor(28 + Math.random() * 58);
  settings.dots = Math.floor(3 + Math.random() * 7);
  settings.glow = +(0.5 + Math.random() * 0.9).toFixed(2);
  settings.fade = +(0.05 + Math.random() * 0.14).toFixed(2);
  settings.curl = +(0.7 + Math.random() * 1.4).toFixed(2);
  settings.depth = +(0.7 + Math.random() * 0.9).toFixed(2);
  settings.pull = +(0.7 + Math.random() * 1.4).toFixed(2);
  presetName.textContent = "MODE: random";
  syncControls();
  saveSettings("random");
}

for (const key of Object.keys(settings)) {
  const input = document.getElementById(key);
  const val = document.getElementById(`${key}Val`);
  input.addEventListener("input", () => {
    settings[key] = Number(input.value);
    val.textContent = input.value;
    presetName.textContent = "MODE: custom";
    saveSettings("custom");
  });
}

document.querySelectorAll("[data-preset]").forEach(button => {
  button.addEventListener("click", () => applyPreset(button.dataset.preset));
});

document.getElementById("randomize").addEventListener("click", randomize);

window.addEventListener("keydown", event => {
  const key = event.key.toLowerCase();

  if (key === "h") panel.classList.toggle("hidden");
  if (key === "c") ctx.clearRect(0, 0, w, h);

  if (key === "f") {
    if (!document.fullscreenElement) document.documentElement.requestFullscreen();
    else document.exitFullscreen();
  }

  if (key === "1") applyPreset("hypnotic");
loadPresenceMode();
  if (key === "2") applyPreset("haunted");
  if (key === "3") applyPreset("storm");
  if (key === "4") applyPreset("singularity");
  if (key === "5") applyPreset("abyss");
  if (key === "6") applyPreset("wonderland");
loadPresenceMode();
  if (key === "7") applyPreset("oracle");

  if (key === "s") {
    screensaver = !screensaver;
    panel.classList.toggle("hidden", screensaver);
    if (screensaver && !document.fullscreenElement) {
      document.documentElement.requestFullscreen().catch(() => {});
    }
  }

  if (key === "p") {
    productionMode = !productionMode;

    if (productionMode) {
      applyPreset("wonderland");
loadPresenceMode();
      screensaver = true;
      panel.classList.add("hidden");

      if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(() => {});
      }
    } else {
      screensaver = false;
      panel.classList.remove("hidden");
    }
  }
});

function resize() {
  dpr = window.devicePixelRatio || 1;
  w = window.innerWidth;
  h = window.innerHeight;
  canvas.width = w * dpr;
  canvas.height = h * dpr;
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  ctx.clearRect(0, 0, w, h);
}

window.addEventListener("resize", resize);
resize();
loadSettings();

if (!localStorage.getItem("wl-spin-city-settings")) {
  applyPreset("wonderland");
loadPresenceMode();
}

function drawHook(cx, cy, angle, radius, curl, color, alpha, clockwise, thickness, t, seed) {
  const dir = clockwise ? 1 : -1;

  ctx.strokeStyle = color;
  ctx.globalAlpha = alpha * settings.glow;
  ctx.lineWidth = thickness;
  ctx.beginPath();

  for (let k = 0; k <= 34; k++) {
    const q = k / 34;
    const a = angle + dir * q * curl * settings.curl;
    const pull = 1.0 - Math.exp(-q * settings.pull);
    const eccentricity = 0.74 + Math.sin(seed * 0.37) * 0.045;
    const r = radius * (0.34 + q * 0.86) * (0.82 + pull * 0.22);
    const wobble = Math.sin(q * Math.PI * 3.5 + angle + seed) * 7 * settings.depth;
    const drift = Math.sin(t * 0.35 + seed) * 3.5;

    const x = cx + Math.cos(a) * (r + wobble + drift);
    const y = cy + Math.sin(a) * (r + wobble - drift) * eccentricity;

    if (k === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }

  ctx.stroke();
}

function drawAttachedDots(cx, cy, angle, radius, curl, count, color, clockwise, t, seed, depth) {
  const dir = clockwise ? 1 : -1;

  for (let j = 0; j < count; j++) {
    const q = (j + 1) / (count + 1);
    const jitter = Math.sin(t * 1.15 + seed + j * 7.3) * 0.014;
    const a = angle + dir * (q + jitter) * curl * settings.curl;
    const pull = 1.0 - Math.exp(-q * settings.pull);
    const r = radius * (0.34 + q * 0.86) * (0.82 + pull * 0.22);
    const wobble = Math.sin(q * Math.PI * 3.5 + angle + seed) * 7 * settings.depth;

    const x = cx + Math.cos(a) * (r + wobble);
    const y = cy + Math.sin(a) * (r + wobble) * 0.74;

    const size = (1.15 + ((j + seed) % 4)) * depth;

    ctx.fillStyle = color;
    const centerWeight = Math.max(0.18, 1.0 - q * 0.38);
    ctx.globalAlpha = (0.54 + Math.sin(t * 2.0 + seed + j) * 0.14) * settings.glow * depth * centerWeight;
    ctx.beginPath();
    ctx.arc(x, y, size, 0, Math.PI * 2);
    ctx.fill();
  }
}

function drawGhostFragments(cx, cy, maxR, rawT) {
  for (const g of ghostFragments) {
    const age = (rawT + g.born) % g.life;
    const q = age / g.life;

    const fadeIn = Math.min(q * 4, 1);
    const fadeOut = Math.min((1 - q) * 4, 1);
    const alpha = Math.max(0, Math.min(fadeIn, fadeOut)) * 0.12 * settings.glow;

    const drift = Math.sin(rawT * 0.12 + g.seed) * 22;
    const r = Math.min(g.radius + drift, maxR * 1.05);
    const a = g.angle + rawT * g.spin + Math.sin(rawT * 0.09 + g.seed) * 0.3;

    let x = cx + Math.cos(a) * r;
    let y = cy + Math.sin(a) * r * 0.74;

    if (cursor.active) {
      const dx = cursor.x - x;
      const dy = cursor.y - y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      const influence = Math.max(0, 1 - dist / 220);

      if (influence > 0) {
        const pull = Math.sin(rawT * 1.7 + g.seed) * 0.5 + 0.5;
        x += dx * influence * 0.08 * pull;
        y += dy * influence * 0.08 * pull;

        ctx.globalAlpha = alpha + influence * 0.16 * settings.glow;
      }
    }

    ctx.strokeStyle = g.color;
    ctx.globalAlpha = alpha;
    ctx.lineWidth = 1;

    ctx.beginPath();
    for (let k = 0; k <= 12; k++) {
      const n = k / 12;
      const aa = a + n * g.curl;
      const rr = 12 + n * 42;
      const px = x + Math.cos(aa) * rr;
      const py = y + Math.sin(aa) * rr * 0.74;

      if (k === 0) ctx.moveTo(px, py);
      else ctx.lineTo(px, py);
    }
    ctx.stroke();
  }
}

function drawWatchers(cx, cy, maxR, rawT) {
  for (let i = 0; i < 5; i++) {
    const color = colors[i % 3];
    const orbit = maxR * (0.22 + i * 0.085);
    const angle = rawT * (i % 2 === 0 ? 0.045 : -0.038) + i * Math.PI * 0.42;

    const x = cx + Math.cos(angle) * orbit;
    const y = cy + Math.sin(angle) * orbit * 0.74;

    const pulse = 1 + Math.sin(rawT * 0.7 + i) * 0.18;
    const size = (10 + i * 1.8) * pulse;

    ctx.strokeStyle = color;
    ctx.globalAlpha = 0.22 * settings.glow;
    ctx.lineWidth = 2.2;
    ctx.beginPath();
    ctx.arc(x, y, size, 0, Math.PI * 2);
    ctx.stroke();

    ctx.globalAlpha = 0.14 * settings.glow;
    ctx.beginPath();
    ctx.arc(x, y, size * 2.2, angle, angle + Math.PI * 1.2);
    ctx.stroke();

    for (let h = 0; h < 3; h++) {
      const hookAngle = angle + h * Math.PI * 0.72 + rawT * 0.12;
      drawHook(x, y, hookAngle, size * (2.4 + h), Math.PI * 0.55, color, 0.12, h % 2 === 0, 1.0, rawT, i * 10 + h);
      drawAttachedDots(x, y, hookAngle, size * (2.4 + h), Math.PI * 0.55, 3, color, h % 2 === 0, rawT, i * 20 + h, 0.8);
    }
  }
}

function frame(ms) {
  const rawT = ms * 0.001;
  const t = rawT * settings.speed;
  const breath = 1.0 + Math.sin(rawT * 0.72) * 0.045;
  const cx = w / 2 + Math.sin(rawT * 0.13) * 8;
  const cy = h / 2 + Math.cos(rawT * 0.11) * 6;
  const maxR = Math.min(w, h) * 0.57 * breath;

  if (screensaver) {
    if (rawT - lastPresetCycle > 90) {
      lastPresetCycle = rawT;
      activePresetIndex = (activePresetIndex + 1) % cyclePresets.length;
      applyPreset(cyclePresets[activePresetIndex]);
      screensaver = true;
      panel.classList.add("hidden");
    }

    settings.glow = 0.82 + Math.sin(rawT * 0.05) * 0.22;
    settings.curl = 1.45 + Math.sin(rawT * 0.043) * 0.38;
    settings.pull = 1.7 + Math.sin(rawT * 0.037) * 0.42;
  }

  ctx.globalCompositeOperation = "source-over";
  ctx.fillStyle = `rgba(5,7,10,${settings.fade})`;
  ctx.fillRect(0, 0, w, h);

  ctx.globalCompositeOperation = "lighter";

  drawGhostFragments(cx, cy, maxR, rawT);
  drawWatchers(cx, cy, maxR, rawT);

  const innerCount = Math.floor(settings.hooks * 0.36);
  const outerCount = Math.floor(settings.hooks * 0.64);
  const shearCount = Math.max(7, Math.floor(settings.hooks * 0.23));

  for (let i = 0; i < innerCount; i++) {
    const depth = 0.8 + (i / Math.max(1, innerCount)) * 0.55;
    const color = colors[i % 3];
    const radius = 26 + i * 8.6;
    const angle = -t * (1.08 + i * 0.021) + i * 0.71;
    const curl = Math.PI * (0.42 + (i % 5) * 0.08);

    drawHook(cx, cy, angle, radius, curl, color, 0.21, true, 1.0 + depth * 0.5, t, i);
    drawAttachedDots(cx, cy, angle, radius, curl, settings.dots, color, true, t, i, depth);
  }

  for (let i = 0; i < outerCount; i++) {
    const depth = 0.55 + (i / Math.max(1, outerCount)) * 0.55;
    const color = colors[(i + 1) % 3];
    const radius = maxR * 0.25 + i * 10.6;
    if (radius > maxR * 1.25) continue;

    const angle = t * (0.30 + i * 0.0055) + i * 0.46;
    const curl = Math.PI * (0.34 + (i % 6) * 0.06);

    const edgeWeight = Math.max(0.28, 1.0 - i / Math.max(1, outerCount) * 0.72);
    drawHook(cx, cy, angle, radius, curl, color, 0.13 * edgeWeight, false, 0.8 + depth * 0.42, t, i + 100);
    drawAttachedDots(cx, cy, angle, radius, curl, Math.max(2, settings.dots - 1), color, false, t, i + 100, depth);
  }

  for (let i = 0; i < shearCount; i++) {
    const clockwise = i % 2 === 0;
    const depth = 1.1;
    const color = colors[(i + 2) % 3];
    const radius = maxR * 0.22 + i * 6.4;
    const angle = (clockwise ? -1 : 1) * t * 0.72 + i * 0.83;
    const curl = Math.PI * 0.74;

    drawHook(cx, cy, angle, radius, curl, color, 0.25, clockwise, 1.5, t, i + 200);
    drawAttachedDots(cx, cy, angle, radius, curl, settings.dots + 1, color, clockwise, t, i + 200, depth);
  }

  // edge darkness to pull attention inward
  ctx.globalCompositeOperation = "source-over";
  const vignette = ctx.createRadialGradient(cx, cy, 40, cx, cy, Math.max(w, h) * 0.62);
  vignette.addColorStop(0, "rgba(0,0,0,0)");
  vignette.addColorStop(0.62, "rgba(0,0,0,0.10)");
  vignette.addColorStop(1, "rgba(0,0,0,0.72)");
  ctx.fillStyle = vignette;
  ctx.fillRect(0, 0, w, h);
  ctx.globalCompositeOperation = "lighter";

  const anomalyPulse = (rawT % 53 > 45 && rawT % 53 < 49) ? 7 : 0;
  const pulse = 6.5 + anomalyPulse + Math.sin(t * 3.2) * 2.5;
  ctx.shadowBlur = 42 * settings.glow;
  ctx.shadowColor = "#00E5FF";
  ctx.fillStyle = "#00E5FF";
  ctx.globalAlpha = 0.78 * settings.glow;
  ctx.beginPath();
  ctx.arc(cx, cy, pulse, 0, Math.PI * 2);
  ctx.fill();

  ctx.shadowBlur = 0;
  ctx.globalCompositeOperation = "source-over";

  requestAnimationFrame(frame);
}

requestAnimationFrame(frame);
