#!/usr/bin/env python3
"""Numba-accelerated spectral subtraction and OLA streaming processor with adaptive VAD noise updating."""

import numpy as np
from numba import jit  # type: ignore[import-not-found]


@jit(nopython=True, cache=True)
def _spectral_subtraction_kernel(
    mag: np.ndarray,
    phase: np.ndarray,
    noise_profile: np.ndarray,
    alpha: float,
    beta: float,
) -> tuple[np.ndarray, np.ndarray]:
    """JIT-compiled kernel for vectorized power subtraction and spectral floor application."""
    noise_power: np.ndarray = noise_profile**2
    signal_power: np.ndarray = mag**2

    cleaned_power: np.ndarray = np.maximum(signal_power - alpha * noise_power, beta * noise_power)
    cleaned_mag: np.ndarray = np.sqrt(cleaned_power)

    real_part: np.ndarray = cleaned_mag * np.cos(phase)
    imag_part: np.ndarray = cleaned_mag * np.sin(phase)
    return real_part.astype(np.float32), imag_part.astype(np.float32)


class SpectralSubtractor:
    def __init__(
        self,
        frame_size: int = 512,
        hop_size: int = 128,
        alpha: float = 2.0,
        beta: float = 0.01,
        update_rate: float = 0.98,
        vad_multiplier: float = 1.4,
    ) -> None:
        self.frame_size: int = frame_size
        self.hop_size: int = hop_size
        self.alpha: float = alpha
        self.beta: float = beta
        self.update_rate: float = update_rate
        self.vad_multiplier: float = vad_multiplier
        self.window: np.ndarray = np.hanning(frame_size).astype(np.float32)
        self.noise_profile: np.ndarray | None = None

    def estimate_noise_profile(self, noise_frames: np.ndarray) -> None:
        windowed: np.ndarray = noise_frames * self.window
        fft_spectra: np.ndarray = np.fft.rfft(windowed, axis=1)
        self.noise_profile = np.mean(np.abs(fft_spectra), axis=0).astype(np.float32)

    def process_frame(self, frame: np.ndarray) -> np.ndarray:
        if self.noise_profile is None:
            raise RuntimeError("Noise profile not initialized.")

        windowed: np.ndarray = frame * self.window
        spectrum: np.ndarray = np.fft.rfft(windowed)
        mag: np.ndarray = np.abs(spectrum).astype(np.float32)
        phase: np.ndarray = np.angle(spectrum).astype(np.float32)

        # Voice Activity Detection (VAD) via sub-band energy comparison
        frame_energy: float = float(np.sum(mag**2))
        noise_energy: float = float(np.sum(self.noise_profile**2))

        # If frame energy is below the VAD threshold (non-speech pause), dynamically update noise profile
        if frame_energy < self.vad_multiplier * noise_energy:
            updated_profile: np.ndarray = (
                self.update_rate * self.noise_profile + (1.0 - self.update_rate) * mag
            )
            self.noise_profile = updated_profile.astype(np.float32)

        # Delegate hot mathematical loop to Numba JIT kernel
        real_part, imag_part = _spectral_subtraction_kernel(
            mag, phase, self.noise_profile, self.alpha, self.beta
        )

        cleaned_spectrum: np.ndarray = real_part + 1j * imag_part
        reconstructed_frame: np.ndarray = np.fft.irfft(cleaned_spectrum, n=self.frame_size)

        result: np.ndarray = reconstructed_frame * self.window
        return result.astype(np.float32)


class OLAStreamProcessor:
    def __init__(self, subtractor: SpectralSubtractor) -> None:
        self.subtractor: SpectralSubtractor = subtractor
        self.frame_size: int = subtractor.frame_size
        self.hop_size: int = subtractor.hop_size

        self.input_buffer: np.ndarray = np.zeros(self.frame_size, dtype=np.float32)
        self.output_buffer: np.ndarray = np.zeros(self.frame_size, dtype=np.float32)

    def process_chunk(self, chunk: np.ndarray) -> np.ndarray:
        num_samples: int = len(chunk)
        output_chunk: np.ndarray = np.zeros(num_samples, dtype=np.float32)

        self.input_buffer[: -self.hop_size] = self.input_buffer[self.hop_size :]
        self.input_buffer[-self.hop_size :] = chunk[: self.hop_size]

        processed_frame: np.ndarray = self.subtractor.process_frame(self.input_buffer)

        self.output_buffer[: -self.hop_size] = self.output_buffer[self.hop_size :]
        self.output_buffer[-self.hop_size :] = 0
        self.output_buffer[: self.frame_size] += processed_frame

        output_chunk[: self.hop_size] = self.output_buffer[: self.hop_size]
        return output_chunk.astype(np.float32)
