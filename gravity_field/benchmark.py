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
        wiener.update(p, floor)
    elapsed = time.perf_counter() - start_time

    audio_duration = len(dummy_audio) / sr
    rtf = elapsed / audio_duration

    metrics = {
        "audio_duration_sec": audio_duration,
        "processing_time_sec": elapsed,
        "real_time_factor": rtf,
        "passes_rtf_target": rtf < 0.25,
    }
    print(
        f"[BENCHMARK] RTF: {rtf:.4f} (Target < 0.25) -> {'PASS' if metrics['passes_rtf_target'] else 'FAIL'}"
    )
    return metrics
