# spin-the-city

`spin-the-city` is a THE∅MATRIX visual app that treats a city as a living rotational field.

## Intent

Create a supernatural city engine where districts orbit, spires sway, and infrastructure appears to self-organize around an unseen gravity well.

## Visual System

- Three large city districts with independent drift, pulse, wobble, and asymmetric orbit.
- A low-opacity atmospheric wave field behind the city.
- Swaying spires that imply unstable architecture.
- A central gravity well that visually anchors the system without turning it into a dashboard.
- Wonderland palette only: `wlBackground`, `wlCyan`, `wlPurple`, `wlGreen`.

## Source

- App view: `apps/spin-the-city/Sources/SpinTheCityView.swift`
- Shared dependencies:
  - `shared/theme/WonderlandColors.swift`
  - `shared/motion/WaveDriftEngine.swift`
  - `shared/effects/AttachedHookShape.swift`

## Verification

Run:

```bash
./scripts/verify-theomatrix.sh
```

Expected result:

```text
RESULT PASS
```

## Recovery

The previous `wl-spin-city` implementation is preserved at:

```text
apps/wl-spin-city/Sources/SpinCityView.swift
```

To remove this app:

```bash
rm -rf apps/spin-the-city
rm docs/spin-the-city.md
```

Then remove `spin-the-city` from:

- `README.md`
- `PROJECT-INSTRUCTIONS.md`
- `intents/theomatrix-build.intent.json`
- `scripts/verify-theomatrix.sh`
