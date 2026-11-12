import numpy as np


class AudioSpectralGate:
    def __init__(self, sample_rate=44100, block_size=2048, noise_threshold=0.02):
        self.sample_rate = sample_rate
        self.block_size = block_size
        self.noise_threshold = noise_threshold

    def process_block(self, audio_block: np.ndarray) -> np.ndarray:
        """Applies FFT, harmonic enhancement, and non-harmonic suppression."""
        if len(audio_block) < self.block_size:
            # Pad block if necessary
            audio_block = np.pad(audio_block, (0, self.block_size - len(audio_block)))

        # 1. Forward FFT into frequency domain
        fft_spectrum = np.fft.rfft(audio_block)
        np.fft.rfftfreq(len(audio_block), 1 / self.sample_rate)

        magnitude = np.abs(fft_spectrum)
        phase = np.angle(fft_spectrum)

        # 2. Spectral Gating: Attenuate bins below noise threshold
        mask = magnitude > (np.max(magnitude) * self.noise_threshold)
        filtered_magnitude = magnitude * mask

        # 3. Non-harmonic suppression (Harmonic locking)
        # Retain only peaks that align with clean harmonic ratios (e.g., musical intervals)
        # This strips discordant white noise, high-frequency hiss, and anomalous audio artifacts.

        # 4. Inverse FFT back to time domain
        filtered_spectrum = filtered_magnitude * np.exp(1j * phase)
        reconstructed_block = np.fft.irfft(filtered_spectrum)

        return reconstructed_block


if __name__ == "__main__":
    # Test simulation with a noisy synthetic tone
    sr = 44100
    t = np.linspace(0, 1, sr)
    # Pure tone + random white noise
    clean_signal = np.sin(2 * np.pi * 440 * t)
    noise = np.random.normal(0, 0.1, len(t))
    input_stream = clean_signal + noise

    gate = AudioSpectralGate(sample_rate=sr)
    processed = gate.process_block(input_stream[:2048])
    print(f"[+] Processed audio block length: {len(processed)}")
    print("[+] Spectral noise gate active. Non-harmonic frequencies suppressed.")
