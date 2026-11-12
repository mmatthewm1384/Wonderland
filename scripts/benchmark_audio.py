#!/usr/bin/env python3
"""Benchmark script to measure latency and Real-Time Factor (RTF) of the OLA streaming DSP pipeline."""

import time

import numpy as np

from gravity_field.audio import OLAStreamProcessor, SpectralSubtractor


def run_benchmark(
    sample_rate: int = 16000,
    duration_seconds: float = 10.0,
    frame_size: int = 512,
    hop_size: int = 128,
):
    print("[*] Initializing SpectralSubtractor & OLAStreamProcessor...")
    subtractor = SpectralSubtractor(frame_size=frame_size, hop_size=hop_size)

    # Estimate noise profile using synthetic noise frames
    noise_frames = np.random.randn(10, frame_size).astype(np.float32) * 0.1
    subtractor.estimate_noise_profile(noise_frames)

    processor = OLAStreamProcessor(subtractor)

    # Generate test audio stream (chunks of hop_size samples)
    total_samples = int(sample_rate * duration_seconds)
    audio_stream = np.random.randn(total_samples).astype(np.float32) * 0.5

    print(
        f"[*] Benchmarking streaming processing over {duration_seconds}s of audio ({total_samples} samples)..."
    )
    print(f"[*] Frame size: {frame_size} | Hop size: {hop_size}")

    # Warm up JIT compiler
    warmup_chunk = audio_stream[:hop_size]
    _ = processor.process_chunk(warmup_chunk)

    # Measure chunk processing execution time
    chunk_times = []
    num_chunks = total_samples // hop_size

    start_global = time.perf_counter()
    for i in range(num_chunks):
        chunk = audio_stream[i * hop_size : (i + 1) * hop_size]

        t0 = time.perf_counter()
        _ = processor.process_chunk(chunk)
        t1 = time.perf_counter()

        chunk_times.append(t1 - t0)

    end_global = time.perf_counter()
    total_elapsed_time = end_global - start_global
    audio_duration = total_samples / sample_rate

    # Real-Time Factor: processing time / audio duration (lower is better, < 1.0 means faster than real-time)
    rtf = total_elapsed_time / audio_duration
    mean_chunk_latency_ms = np.mean(chunk_times) * 1000
    max_chunk_latency_ms = np.max(chunk_times) * 1000

    print("\n" + "=" * 40)
    print(" AUDIO BENCHMARK RESULTS ")
    print("=" * 40)
    print(f"Audio Duration      : {audio_duration:.2f} s")
    print(f"Total Processing Time: {total_elapsed_time:.4f} s")
    print(
        f"Real-Time Factor (RTF): {rtf:.4f} "
        + ("[PASS - Real-time capable]" if rtf < 1.0 else "[FAIL - Too slow]")
    )
    print(f"Mean Chunk Latency  : {mean_chunk_latency_ms:.3f} ms")
    print(f"Max Chunk Latency   : {max_chunk_latency_ms:.3f} ms")
    print("=" * 40)


if __name__ == "__main__":
    run_benchmark()
