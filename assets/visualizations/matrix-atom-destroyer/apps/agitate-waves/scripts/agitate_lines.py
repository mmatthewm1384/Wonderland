#!/usr/bin/env python3
from pathlib import Path
import math
import time

root = Path(__file__).resolve().parents[1]
out = root / "exports" / "agitate-lines.txt"
out.parent.mkdir(parents=True, exist_ok=True)

width = 96
height = 28
frames = 12

chars = " .:-=+*#%@"

with out.open("w") as f:
    for frame in range(frames):
        f.write(f"FRAME {frame}\n")
        t = frame / frames * math.tau
        for y in range(height):
            row = []
            for x in range(width):
                v = (
                    math.sin(x * 0.16 + t)
                    + math.sin(y * 0.41 - t)
                    + math.sin((x + y) * 0.08 + t * 2)
                ) / 3
                idx = int((v + 1) / 2 * (len(chars) - 1))
                row.append(chars[idx])
            f.write("".join(row) + "\n")
        f.write("\n")
        time.sleep(0.01)

print(f"PASS wrote {out}")
