"""Digital Signal Processing modules for spectral analysis and filtering."""

from typing import Any, cast

import numpy as np
from numpy.typing import NDArray

from gravity_field.dsp_base import LevelSurface


class STFT:
    """Short-Time Fourier Transform processor."""

    def __init__(self, n_fft: int = 1024, hop: int = 256) -> None:
        self.n_fft = n_fft
        self.hop = hop
        self.n_bins = n_fft // 2 + 1

    def frames(self, audio: NDArray[Any]) -> Any:
        """Yield audio frames."""
        for i in range(0, len(audio) - self.n_fft + 1, self.hop):
            yield audio[i : i + self.n_fft]

    def transform(self, frame: NDArray[Any]) -> NDArray[Any]:
        """Compute STFT transform for a frame."""
        res = np.fft.rfft(frame * np.hanning(len(frame)))
        return cast(NDArray[Any], res)


class WienerGain:
    """Wiener filter gain processor for noise suppression."""

    def __init__(self, n_bins: int) -> None:
        self.n_bins = n_bins

    def update(self, p: NDArray[Any], floor: NDArray[Any]) -> NDArray[Any]:
        """Update Wiener gain."""
        g = p / (p + floor + 1e-10)
        return cast(NDArray[Any], g.astype(np.float32))


def hz_to_erb(f: np.ndarray) -> np.ndarray:
    """Convert Hertz to Equivalent Rectangular Bandwidth (ERB) rate."""
    result: np.ndarray = 11.17 * np.log(1.0 + 46.5 * f / (f + 14000.0))
    return result.astype(np.float32)


def erb_to_hz(erb: np.ndarray) -> np.ndarray:
    """Convert Equivalent Rectangular Bandwidth (ERB) rate to Hertz."""
    result: np.ndarray = 14000.0 * (np.exp(erb / 11.17) - 1.0) / (46.5 - np.exp(erb / 11.17) + 1.0)
    return result.astype(np.float32)


class MultibandLevelSurface(LevelSurface):
    """ERB-spaced multiband LevelSurface tracker."""

    def __init__(
        self,
        n_bins: int,
        sample_rate: float = 48000.0,
        n_bands: int = 32,
        **kwargs: Any,
    ) -> None:
        super().__init__(n_bins, **kwargs)
        freqs: np.ndarray = np.fft.rfftfreq((n_bins - 1) * 2, 1.0 / sample_rate)
        min_erb, max_erb = float(hz_to_erb(freqs[1])), float(hz_to_erb(freqs[-1]))
        self.band_edges: np.ndarray = erb_to_hz(np.linspace(min_erb, max_erb, n_bands + 1))
        self.bin_bands: np.ndarray = np.digitize(freqs, self.band_edges) - 1
        self.bin_bands = np.clip(self.bin_bands, 0, n_bands - 1).astype(np.int64)
        self.n_bands: int = n_bands

    def update(self, power: np.ndarray) -> NDArray[Any]:
        band_power: np.ndarray = np.array(
            [np.mean(power[self.bin_bands == b]) for b in range(self.n_bands)],
            dtype=np.float32,
        )
        res = super().update(band_power)
        return cast(NDArray[Any], res)


def apply_phase_randomization(spec: np.ndarray, g: np.ndarray, g_min: float) -> NDArray[Any]:
    """Randomize phase for bins clamped to the spectral floor to eliminate musical noise."""
    mask: np.ndarray = g <= (g_min * 1.2)
    if not np.any(mask):
        return spec.astype(np.complex64)
    magnitudes: np.ndarray = np.abs(spec) * g
    phases: np.ndarray = np.angle(spec)
    phases[mask] = np.random.uniform(-np.pi, np.pi, size=int(np.sum(mask)))
    result: np.ndarray = magnitudes * np.exp(1j * phases)
    return result.astype(np.complex64)
