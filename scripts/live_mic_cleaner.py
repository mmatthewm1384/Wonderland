#!/usr/bin/env python3
"""Real-time microphone noise suppression script using PyAudio and OLAStreamProcessor."""

import numpy as np
import pyaudio

from gravity_field.audio import OLAStreamProcessor, SpectralSubtractor

# Audio stream parameters
SAMPLE_RATE = 16000
HOP_SIZE = 128
FRAME_SIZE = 512
CHANNELS = 1
FORMAT = pyaudio.paFloat32


def callback(in_data, frame_count, time_info, status):
    """PyAudio non-blocking stream callback for real-time processing."""
    # Convert input byte buffer to float32 NumPy array
    audio_chunk = np.frombuffer(in_data, dtype=np.float32)

    # Process chunk through OLA stream processor
    processed_chunk = stream_processor.process_chunk(audio_chunk)

    # Return processed audio back to the playback stream
    return (processed_chunk.tobytes(), pyaudio.paContinue)


def main():
    global stream_processor

    print("[*] Initializing SpectralSubtractor & OLAStreamProcessor...")
    subtractor = SpectralSubtractor(frame_size=FRAME_SIZE, hop_size=HOP_SIZE, alpha=2.0, beta=0.01)

    # Estimate initial noise profile (using quiet background noise simulation for startup)
    initial_noise = np.random.randn(10, FRAME_SIZE).astype(np.float32) * 0.05
    subtractor.estimate_noise_profile(initial_noise)

    stream_processor = OLAStreamProcessor(subtractor)

    p = pyaudio.PyAudio()

    print(f"[*] Opening live audio stream ({SAMPLE_RATE}Hz, hop size: {HOP_SIZE})...")

    try:
        # Open bi-directional stream (input from microphone, output to speakers/headphones)
        stream = p.open(
            format=FORMAT,
            channels=CHANNELS,
            rate=SAMPLE_RATE,
            input=True,
            output=True,
            frames_per_buffer=HOP_SIZE,
            stream_callback=callback,
        )

        stream.start_stream()
        print(
            "[+] Live noise suppression active. Speak into your microphone. Press Ctrl+C to exit."
        )

        while stream.is_active():
            import time

            time.sleep(0.1)

    except KeyboardInterrupt:
        print("\n[*] Stopping live audio stream...")
    except Exception as e:
        print(f"[-] Error during live stream execution: {e}")
    finally:
        if "stream" in locals() and stream.is_active():
            stream.stop_stream()
            stream.close()
        p.terminate()
        print("[+] PyAudio terminated. Clean exit.")


if __name__ == "__main__":
    main()
