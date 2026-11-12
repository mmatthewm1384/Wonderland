import os
import sys

# Add target release directory or local build path where aetheris_core.so resides
sys.path.append(os.path.abspath("core/target/release"))

try:
    import aetheris_core

    print("[AETHERIS-PY] Successfully imported aetheris_core extension module.")
except ImportError as e:
    print(f"[AETHERIS-PY] Failed to import aetheris_core: {e}")
    sys.exit(1)

# Test vectors
v1 = [1.0, 0.0, 0.0, 1.0]
v2 = [1.0, 0.0, 0.0, 1.0]
v3 = [0.0, 1.0, 1.0, 0.0]

sim_identical = aetheris_core.VectorEngine.cosine_similarity(v1, v2)
sim_orthogonal = aetheris_core.VectorEngine.cosine_similarity(v1, v3)

print(f"[AETHERIS-PY] Cosine similarity (identical): {sim_identical:.4f} (Expected: ~1.0)")
print(f"[AETHERIS-PY] Cosine similarity (orthogonal): {sim_orthogonal:.4f} (Expected: ~0.0)")

assert abs(sim_identical - 1.0) < 1e-5, "Identical vector test failed!"
assert abs(sim_orthogonal) < 1e-5, "Orthogonal vector test failed!"
print("[AETHERIS-PY] PASSED: All SIMD vector Python bindings verified successfully.")
