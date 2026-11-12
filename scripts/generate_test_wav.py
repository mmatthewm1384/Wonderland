#!/usr/bin/env python3
"""Generate a synthetic WAV file with a time-varying noise floor for DSP validation."""

import numpy as np
from scipy.io import wavfile


def generate_dynamic_noise_wav(
    filename: str = "dynamic_test.wav",
    duration: float = 5.0,
    sample_rate: int = 16000,
) -> None:
    print(f"[*] Generating synthetic audio: {filename} ({duration}s @ {sample_rate}Hz)...")

    t = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)

    # 1. Base signal: Frequency-modulated tone (simulating voice formants/chirps)
    signal = np.sin(2 * np.pi * (440 + 220 * np.sin(2 * np.pi * 0.5 * t)) * t) * 0.4

    # 2. Time-varying noise envelope:
    #    - 0.0s to 1.0s: Low background noise (initial calibration zone)
    #    - 1.0s to 3.0s: Heavy noise burst (stress test)
    #    - 3.0s to 5.0s: Moderate fluctuating noise
    noise_envelope = np.ones_like(t) * 0.02
    burst_start = int(sample_rate * 1.0)
    burst_end = int(sample_rate * 3.0)
    tail_start = int(sample_rate * 3.0)

    noise_envelope[burst_start:burst_end] = 0.30
    noise_envelope[tail_start:] = 0.12

    # Add random white noise modulated by the envelope
    white_noise = np.random.randn(len(t)).astype(np.float32)
    noise = white_noise * noise_envelope

    # Combine signal and noise
    audio = (signal + noise).astype(np.float32)

    # Peak normalization to prevent clipping
    audio /= np.max(np.abs(audio)) + 1e-6

    wavfile.write(filename, sample_rate, audio)
    print(f"[+] Successfully generated {filename}")


if __name__ == "__main__":
    generate_dynamic_noise_wav()
