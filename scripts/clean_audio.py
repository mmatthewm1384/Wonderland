#!/usr/bin/env python3
"""CLI utility to apply Numba-accelerated spectral subtraction and OLA noise suppression to WAV files."""

import argparse
import sys
from pathlib import Path

import numpy as np
from numba import jit
from scipy.io import wavfile


@jit(nopython=True, cache=True)
def _spectral_subtraction_kernel(mag, phase, noise_profile, alpha, beta):
    """JIT-compiled kernel for vectorized power subtraction and spectral floor application."""
    noise_power = noise_profile**2
    signal_power = mag**2

    cleaned_power = np.maximum(signal_power - alpha * noise_power, beta * noise_power)
    cleaned_mag = np.sqrt(cleaned_power)

    real_part = cleaned_mag * np.cos(phase)
    imag_part = cleaned_mag * np.sin(phase)
    return real_part, imag_part


class SpectralSubtractor:
    def __init__(
        self,
        frame_size: int = 512,
        hop_size: int = 128,
        alpha: float = 2.0,
        beta: float = 0.01,
    ):
        self.frame_size = frame_size
        self.hop_size = hop_size
        self.alpha = alpha
        self.beta = beta
        self.window = np.hanning(frame_size)
        self.noise_profile = None

    def estimate_noise_profile(self, noise_frames: np.ndarray) -> None:
        windowed = noise_frames * self.window
        fft_spectra = np.fft.rfft(windowed, axis=1)
        self.noise_profile = np.mean(np.abs(fft_spectra), axis=0)

    def process_frame(self, frame: np.ndarray) -> np.ndarray:
        if self.noise_profile is None:
            raise RuntimeError("Noise profile not initialized.")

        windowed = frame * self.window
        spectrum = np.fft.rfft(windowed)
        mag = np.abs(spectrum)
        phase = np.angle(spectrum)

        real_part, imag_part = _spectral_subtraction_kernel(
            mag, phase, self.noise_profile, self.alpha, self.beta
        )

        cleaned_spectrum = real_part + 1j * imag_part
        reconstructed_frame = np.fft.irfft(cleaned_spectrum, n=self.frame_size)
        return reconstructed_frame * self.window


class OLAStreamProcessor:
    def __init__(self, subtractor: SpectralSubtractor):
        self.subtractor = subtractor
        self.frame_size = subtractor.frame_size
        self.hop_size = subtractor.hop_size
        self.input_buffer = np.zeros(self.frame_size, dtype=np.float32)
        self.output_buffer = np.zeros(self.frame_size, dtype=np.float32)

    def process_chunk(self, chunk: np.ndarray) -> np.ndarray:
        num_samples = len(chunk)
        output_chunk = np.zeros(num_samples, dtype=np.float32)

        self.input_buffer[: -self.hop_size] = self.input_buffer[self.hop_size :]
        self.input_buffer[-self.hop_size :] = chunk[: self.hop_size]

        processed_frame = self.subtractor.process_frame(self.input_buffer)

        self.output_buffer[: -self.hop_size] = self.output_buffer[self.hop_size :]
        self.output_buffer[-self.hop_size :] = 0
        self.output_buffer[: self.frame_size] += processed_frame

        output_chunk[: self.hop_size] = self.output_buffer[: self.hop_size]
        return output_chunk


def process_wav(
    input_path: Path,
    output_path: Path,
    alpha: float,
    beta: float,
    frame_size: int,
    hop_size: int,
) -> None:
    print(f"[*] Reading audio from {input_path}...")
    sample_rate, data = wavfile.read(input_path)

    # Convert multi-channel audio to mono for processing if needed, or handle channels
    if data.ndim > 1:
        print("[*] Multi-channel audio detected. Converting to mono for spectral estimation...")
        mono_data = np.mean(data, axis=1).astype(np.float32)
    else:
        mono_data = data.astype(np.float32)

    # Normalize integer PCM ranges to float [-1.0, 1.0]
    max_val = np.iinfo(data.dtype).max if np.issubdtype(data.dtype, np.integer) else 1.0
    audio_normalized = mono_data / max_val

    subtractor = SpectralSubtractor(
        frame_size=frame_size, hop_size=hop_size, alpha=alpha, beta=beta
    )

    # Estimate noise profile from the first 0.5 seconds (assuming stationary initial noise)
    noise_samples_count = int(sample_rate * 0.5)
    if len(audio_normalized) < noise_samples_count:
        noise_samples_count = len(audio_normalized)

    noise_segment = audio_normalized[:noise_samples_count]
    num_noise_frames = len(noise_segment) // hop_size
    if num_noise_frames > 0:
        noise_frames = np.array(
            [
                noise_segment[i * hop_size : i * hop_size + frame_size]
                for i in range(num_noise_frames)
                if i * hop_size + frame_size <= len(noise_segment)
            ]
        )
        if len(noise_frames) > 0:
            subtractor.estimate_noise_profile(noise_frames)
        else:
            subtractor.noise_profile = np.ones(frame_size // 2 + 1, dtype=np.float32) * 0.01
    else:
        subtractor.noise_profile = np.ones(frame_size // 2 + 1, dtype=np.float32) * 0.01

    processor = OLAStreamProcessor(subtractor)

    print("[*] Applying spectral subtraction filter...")
    output_audio = np.zeros_like(audio_normalized)

    for i in range(0, len(audio_normalized), hop_size):
        chunk = audio_normalized[i : i + hop_size]
        if len(chunk) < hop_size:
            chunk = np.pad(chunk, (0, hop_size - len(chunk)))

        processed = processor.process_chunk(chunk)
        end_idx = min(i + hop_size, len(output_audio))
        output_audio[i:end_idx] = processed[: end_idx - i]

    # Rescale back to original datatype range
    output_scaled = (output_audio * max_val).astype(data.dtype)

    print(f"[*] Writing cleaned audio to {output_path}...")
    wavfile.write(output_path, sample_rate, output_scaled)
    print("[+] Audio processing complete.")


def main():
    parser = argparse.ArgumentParser(
        description="Clean audio using Numba-accelerated spectral subtraction."
    )
    parser.add_argument("input", type=Path, help="Path to input WAV file")
    parser.add_argument("output", type=Path, help="Path to output cleaned WAV file")
    parser.add_argument(
        "--alpha", type=float, default=2.0, help="Over-subtraction factor (default: 2.0)"
    )
    parser.add_argument(
        "--beta", type=float, default=0.01, help="Spectral floor parameter (default: 0.01)"
    )
    parser.add_argument("--frame-size", type=int, default=512, help="FFT frame size (default: 512)")
    parser.add_argument("--hop-size", type=int, default=128, help="Hop size (default: 128)")

    args = parser.parse_args()

    if not args.input.exists():
        print(f"[-] Error: Input file {args.input} not found.")
        sys.exit(1)

    process_wav(args.input, args.output, args.alpha, args.beta, args.frame_size, args.hop_size)


if __name__ == "__main__":
    main()
