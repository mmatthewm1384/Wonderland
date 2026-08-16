# Nexil

Nexil is Wonderland's native macOS clipboard memory.

> Copy once. Remember everything. Paste anything.

## Architecture

Nexil is local-first clipboard memory. It is intentionally separate from Crystal durable memory. Clipboard content is never promoted to Crystal implicitly.

```text
macOS Pasteboard
      |
      v
 ClipboardMonitor
      |
      v
  Policy + Capture
      |
      v
 Encrypted Nexil Store
      |
      +--> Search / Recall
      +--> Paste
      +--> Lifecycle
      +--> Explicit Crystal promotion (future)
```

Nexil uses `NSPasteboard.general`, Apple's pasteboard interface for ordinary copy/paste operations. See Apple's `NSPasteboard` documentation for the system pasteboard model and access behavior.

## Current capabilities

- Native AppKit + SwiftUI menu-bar application
- Global `Option-Space` recall
- Text, URL, code, rich-text, image, and file capture
- Local encrypted persistence using CryptoKit AES-GCM
- Per-install encryption key stored in Keychain
- SHA-256 content identity/deduplication
- Search
- Pinning
- Delete and clear-unpinned
- Retention policy
- Secret capture policy
- Application exclusion policy
- Direct paste to the previous foreground application

## Build

```sh
cd nexil
make build
make app
open .build/Nexil.app
```

For development:

```sh
cd nexil
make run
```

The app is built as a menu-bar-only `.app` bundle. The bundle metadata sets `LSUIElement`, so Nexil does not create a normal Dock application presence.

## Security boundary

Nexil's clipboard database is encrypted at rest. The encryption key is not stored beside the clipboard database; it is held in the macOS Keychain.

Nexil does not use a cloud service, account, telemetry pipeline, or network dependency for clipboard memory.

## Verification gates

1. Native release build
2. App bundle launch
3. Pasteboard capture
4. Deduplication and persistence
5. Encryption/recovery test
6. Secret/exclusion policy tests
7. Paste verification
8. Lifecycle verification
9. Evidence/conformance bundle
10. Crystal promotion boundary
