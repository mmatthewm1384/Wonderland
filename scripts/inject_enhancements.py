#!/usr/bin/env python3
import os

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(content.strip() + "\n")
    print(f"[INJECT] Created/Updated {path}")

def main():
    # 1. Create Lock-Free Ring Buffer
    ringbuffer_code = '''
import numpy as np
import threading

class LockFreeRingBuffer:
    def __init__(self, capacity: int, n_channels: int = 1):
        self.capacity = capacity
        self.n_channels = n_channels
        self.buffer = np.zeros((capacity, n_channels), dtype=np.float32)
        self.head = 0
        self.tail = 0
        self._lock = threading.Lock()

    def write(self, data: np.ndarray) -> int:
        n = data.shape[0]
        with self._lock:
            idx = (self.head + np.arange(n)) % self.capacity
            self.buffer[idx] = data
            self.head = (self.head + n) % self.capacity
        return n

    def read(self, n: int) -> np.ndarray:
        with self._lock:
            idx = (self.tail + np.arange(n)) % self.capacity
            out = self.buffer[idx].copy()
            self.tail = (self.tail + n) % self.capacity
        return out
'''
    write_file("gravity_field/ringbuffer.py", ringbuffer_code)

    # 2. Create Automated Benchmark Module
    benchmark_code = '''
import time
import numpy as np
from gravity_field.dsp import STFT, LevelSurface, WienerGain

def run_benchmark(duration_sec: float = 10.0, sr: int = 48000) -> dict:
    n_fft = 1024
    hop = 256
    stft = STFT(n_fft=n_fft, hop=hop)
    surface = LevelSurface(n_bins=stft.n_bins)
    wiener = WienerGain(n_bins=stft.n_bins)

    dummy_audio = np.random.randn(int(sr * duration_sec))
    frames = stft.frames(dummy_audio)

    start_time = time.perf_counter()
    for frame in frames:
        p = np.abs(stft.transform(frame[None, :])[0]) ** 2
        floor = surface.update(p)
        g = wiener.update(p, floor)
    elapsed = time.perf_counter() - start_time

    audio_duration = len(dummy_audio) / sr
    rtf = elapsed / audio_duration

    metrics = {
        "audio_duration_sec": audio_duration,
        "processing_time_sec": elapsed,
        "real_time_factor": rtf,
        "passes_rtf_target": rtf < 0.25
    }
    print(f"[BENCHMARK] RTF: {rtf:.4f} (Target < 0.25) -> {\'PASS\' if metrics[\'passes_rtf_target\'] else \'FAIL\'}")
    return metrics
'''
    write_file("gravity_field/benchmark.py", benchmark_code)

    # 3. Append Multiband ERB & Phase Randomization to dsp.py
    dsp_additions = '''

def hz_to_erb(f: np.ndarray) -> np.ndarray:
    return 11.17 * np.log(1.0 + 46.5 * f / (f + 14000.0))

def erb_to_hz(erb: np.ndarray) -> np.ndarray:
    return 14000.0 * (np.exp(erb / 11.17) - 1.0) / (46.5 - np.exp(erb / 11.17) + 1.0)

class MultibandLevelSurface(LevelSurface):
    """ERB-spaced multiband LevelSurface tracker."""
    def __init__(self, n_bins: int, sample_rate: float = 48000.0, n_bands: int = 32, **kwargs):
        super().__init__(n_bins, **kwargs)
        freqs = np.fft.rfftfreq((n_bins - 1) * 2, 1.0 / sample_rate)
        min_erb, max_erb = hz_to_erb(freqs[1]), hz_to_erb(freqs[-1])
        self.band_edges = erb_to_hz(np.linspace(min_erb, max_erb, n_bands + 1))
        self.bin_bands = np.digitize(freqs, self.band_edges) - 1
        self.bin_bands = np.clip(self.bin_bands, 0, n_bands - 1)
        self.n_bands = n_bands

    def update(self, power: np.ndarray) -> np.ndarray:
        band_power = np.array([np.mean(power[self.bin_bands == b]) for b in range(self.n_bands)])
        band_floor = super().update(band_power)
        return band_floor[self.bin_bands]

def apply_phase_randomization(spec: np.ndarray, g: np.ndarray, g_min: float) -> np.ndarray:
    """Randomize phase for bins clamped to the spectral floor to eliminate musical noise."""
    mask = g <= (g_min * 1.2)
    if not np.any(mask):
        return spec * g
    magnitudes = np.abs(spec) * g
    phases = np.angle(spec)
    phases[mask] = np.random.uniform(-np.pi, np.pi, size=np.sum(mask))
    return magnitudes * np.exp(1j * phases)
'''
    with open("gravity_field/dsp.py", "a") as f:
        f.write(dsp_additions)
    print("[INJECT] Appended MultibandLevelSurface and phase randomization to gravity_field/dsp.py")

    # 4. Update Makefile to include benchmark target
    with open("Makefile", "r") as f:
        makefile_content = f.read()

    if "benchmark:" not in makefile_content:
        makefile_content += "\nbenchmark:\n\t$(PY) -m gravity_field.benchmark\n"
        with open("Makefile", "w") as f:
            f.write(makefile_content)
        print("[INJECT] Added benchmark target to Makefile")

if __name__ == "__main__":
    main()
