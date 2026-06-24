#!/bin/bash
echo "=== wl veil logs ==="
echo "No persistent logs (anonymity design)."
nerdctl logs veil 2>/dev/null || echo "None present."
