import numpy as np
import pytest

from gravity_field.audio import OLAStreamProcessor, SpectralSubtractor


def test_subtractor_initialization():
    """Verify default parameters and initial state of SpectralSubtractor."""
    subtractor = SpectralSubtractor(frame_size=512, hop_size=128)
    assert subtractor.frame_size == 512
    assert subtractor.hop_size == 128
    assert subtractor.alpha == 2.0
    assert subtractor.beta == 0.01
    assert subtractor.noise_profile is None


def test_uninitialized_noise_profile_raises():
    """Ensure calling process_frame without estimating noise raises RuntimeError."""
    subtractor = SpectralSubtractor(frame_size=512, hop_size=128)
    frame = np.zeros(512, dtype=np.float32)
    with pytest.raises(RuntimeError, match="Noise profile not initialized"):
        subtractor.process_frame(frame)


def test_noise_profile_estimation():
    """Verify noise profile estimation calculates correct magnitude spectrum shape."""
    subtractor = SpectralSubtractor(frame_size=512, hop_size=128)
    noise_frames = np.random.randn(10, 512).astype(np.float32) * 0.1
    subtractor.estimate_noise_profile(noise_frames)

    assert subtractor.noise_profile is not None
    assert len(subtractor.noise_profile) == 257
    assert subtractor.noise_profile.dtype == np.float32


def test_process_frame():
    """Verify single frame spectral subtraction returns valid array shape and type."""
    subtractor = SpectralSubtractor(frame_size=512, hop_size=128)
    noise_frames = np.random.randn(10, 512).astype(np.float32) * 0.1
    subtractor.estimate_noise_profile(noise_frames)

    frame = np.random.randn(512).astype(np.float32) * 0.5
    processed = subtractor.process_frame(frame)

    assert processed.shape == (512,)
    assert processed.dtype == np.float32
    assert not np.isnan(processed).any()


def test_adaptive_vad_noise_updating():
    """Verify that low-energy non-speech frames dynamically update the noise profile."""
    subtractor = SpectralSubtractor(
        frame_size=512, hop_size=128, update_rate=0.5, vad_multiplier=10.0
    )

    # Initialize with baseline quiet noise
    initial_noise = np.random.randn(1, 512).astype(np.float32) * 0.05
    subtractor.estimate_noise_profile(initial_noise)
    initial_profile_mean = np.mean(subtractor.noise_profile)

    # Process a pause frame with energy falling below the relaxed VAD multiplier threshold
    pause_frame = np.random.randn(512).astype(np.float32) * 0.08
    _ = subtractor.process_frame(pause_frame)

    updated_profile_mean = np.mean(subtractor.noise_profile)

    # The noise profile mean should have shifted due to VAD adaptation
    assert updated_profile_mean != initial_profile_mean


def test_ola_stream_processor():
    """Verify continuous streaming chunk processing via OLAStreamProcessor."""
    subtractor = SpectralSubtractor(frame_size=512, hop_size=128)
    noise_frames = np.random.randn(10, 512).astype(np.float32) * 0.1
    subtractor.estimate_noise_profile(noise_frames)

    processor = OLAStreamProcessor(subtractor)
    chunk = np.random.randn(128).astype(np.float32) * 0.5
    output_chunk = processor.process_chunk(chunk)

    assert output_chunk.shape == (128,)
    assert output_chunk.dtype == np.float32
    assert not np.isnan(output_chunk).any()
