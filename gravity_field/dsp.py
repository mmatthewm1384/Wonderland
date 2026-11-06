

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
