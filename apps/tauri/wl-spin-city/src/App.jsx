import { useEffect, useRef } from "react";
import { SpinCityEngine } from "./matrix/spin-city-engine.js";
import "./style.css";

export default function App() {
  const canvasRef = useRef(null);
  const engineRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext("2d", { alpha: false });

    function resize() {
      const dpr = window.devicePixelRatio || 1;
      canvas.width = Math.floor(window.innerWidth * dpr);
      canvas.height = Math.floor(window.innerHeight * dpr);
      canvas.style.width = `${window.innerWidth}px`;
      canvas.style.height = `${window.innerHeight}px`;

      if (!engineRef.current) {
        engineRef.current = new SpinCityEngine(canvas.width, canvas.height);
      } else {
        engineRef.current.resize(canvas.width, canvas.height);
      }
    }

    function frame(time) {
      engineRef.current.tick(time);
      engineRef.current.draw(ctx);
      requestAnimationFrame(frame);
    }

    resize();
    requestAnimationFrame(frame);
    window.addEventListener("resize", resize);

    return () => window.removeEventListener("resize", resize);
  }, []);

  return <canvas ref={canvasRef} />;
}
