# Zero-Trust Investigation — Wonderland Component

**Classification:** OPERATOR EYES ONLY  
**Date:** 2026-06-22

## Purpose
Investigation of NIST SP 800-207 ZTA and integration blueprint for Wonderland (ephemeral agents, FSEvent apps, companions, visuals, wl/nerdctl).

## Files
- `zero-trust-report.md` — Full report + mappings + recommendations.
- `zt_intent_generator.py` — Tool for ZT-augmented intents and policies.

## Quick Start
```bash
cd ~/Wonderland/Wonderland-v4/zero-trust-investigation
python3 zt_intent_generator.py generate --service catalog-agent --risk 25
python3 zt_intent_generator.py policy --type pep
