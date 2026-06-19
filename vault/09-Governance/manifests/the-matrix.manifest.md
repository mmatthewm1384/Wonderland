# THE∅MATRIX Manifest

## Identity

THE∅MATRIX is the Wonderland visual app suite.

## Apps

| Role | App | Path |
|---|---|---|
| Focus | wl-spin-city | apps/tauri/wl-spin-city |
| Ambient | wl-agitate | apps/tauri/wl-agitate |
| Energy | wl-matrix | apps/tauri/wl-matrix |
| Emergence | matrix-fluderation | apps/matrix/matrix-fluderation |

## Commands

- wl-matrix-suite doctor
- wl-matrix-suite bundle-doctor
- wl-matrix-suite recertify
- wl-matrix-suite build
- wl-matrix-suite report

## Launch

- wl-matrix-suite focus
- wl-matrix-suite ambient
- wl-matrix-suite energy
- wl-matrix-suite emergence

## Screensaver

- wl-matrix-suite start 300
- wl-matrix-suite state
- wl-matrix-suite log
- wl-matrix-suite stop

## Verification

Run:

    wl-the-matrix doctor
    wl-matrix-suite recertify

Expected:

    RESULT PASS

## Recovery

If a bundle is missing:

    wl-matrix-suite build
    wl-matrix-suite bundle-doctor

If screensaver is stuck:

    wl-matrix-suite stop
    pkill -f "wl-matrix-suite screensaver"

If a Tauri app dependency fails:

    cd <app-path>
    rm -rf node_modules package-lock.json
    npm install --include=optional
    npm run tauri build

## Rollback

    git restore bin/wl-matrix-suite bin/wl-the-matrix
    git restore vault/09-Governance/registry/the-matrix-apps.json
    git restore vault/09-Governance/manifests/the-matrix.manifest.md
