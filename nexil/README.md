# Nexil

Nexil is Wonderland's native macOS menu-bar clipboard memory.

## Contract

- Native AppKit + SwiftUI; no web runtime.
- `⌥Space` opens the recall surface.
- Clipboard data remains local to the Mac.
- Captured objects are encrypted at rest with AES-GCM.
- The encryption key is stored in the macOS Keychain and scoped to this device.
- Private-key and common API-token patterns are rejected by default.
- Keychain/password-manager applications are excluded by default.
- Normal objects expire after 30 days; pinned objects are retained.
- Text, rich text, images, files, URLs, and code are typed clipboard objects.
- Crystal promotion is deliberately explicit and is not part of automatic capture.

## Build

```sh
cd nexil
swift build -c release
swift test
sh build-app.sh
open build/Nexil.app
```

The generated app uses `LSUIElement`, so it remains a menu-bar/accessory application rather than a normal Dock application.

## Data boundary

```text
macOS Pasteboard
      |
      v
    Nexil
      |
      +--> encrypted local clipboard memory
      |
      +--> explicit future action --> Crystal
```

Nexil is short-term clipboard memory. Crystal remains durable, governed Wonderland memory.
