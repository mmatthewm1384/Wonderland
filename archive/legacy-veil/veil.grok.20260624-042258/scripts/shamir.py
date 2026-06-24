#!/usr/bin/env python3
# GF(256) polynomial arithmetic exploration for SSS
# Field: GF(2^8) with irreducible polynomial x^8 + x^4 + x^3 + x + 1 (0x11b)

def gf256_add(a, b):
    return a ^ b  # XOR for GF(2) addition

def gf256_mul(a, b):
    p = 0
    for _ in range(8):
        if b & 1:
            p ^= a
        hi_bit = a & 0x80
        a <<= 1
        if hi_bit:
            a ^= 0x1b  # irreducible poly
        a &= 0xff
        b >>= 1
    return p

def gf256_inverse(a):
    if a == 0:
        raise ValueError("No inverse for 0")
    # Extended Euclidean Algorithm for GF(256)
    t, newt = 0, 1
    r, newr = 0, a
    while newr != 0:
        quotient = r // newr
        t, newt = newt, t - quotient * newt
        r, newr = newr, r - quotient * newr
    if r != 1:
        raise ValueError("No inverse")
    return t % 256

# ... (split_secret, reconstruct, lagrange as in previous fixed version)
if __name__ == "__main__":
    print("GF(256) arithmetic ready for SSS.")
