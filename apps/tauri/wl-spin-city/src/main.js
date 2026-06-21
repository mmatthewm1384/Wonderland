import { SpinCityEngine } from "./matrix/spin-city-engine.js";
import "./style.css";

const canvas = document.createElement("canvas");
document.body.appendChild(canvas);

const ctx = canvas.getContext("2d", { alpha: false });
let engine;

function resize() {
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.floor(window.innerWidth * dpr);
  canvas.height = Math.floor(window.innerHeight * dpr);
  canvas.style.width = `${window.innerWidth}px`;
  canvas.style.height = `${window.innerHeight}px`;

  if (!engine) engine = new SpinCityEngine(canvas.width, canvas.height);
  else engine.resize(canvas.width, canvas.height);
}

function frame(time) {
  engine.tick(time);
  engine.draw(ctx);
  requestAnimationFrame(frame);
}

window.addEventListener("resize", resize);
resize();
requestAnimationFrame(frame);
