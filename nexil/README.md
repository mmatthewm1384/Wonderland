# Nexil

**Nexil** is Wonderland's native macOS clipboard memory: a quiet menu-bar application that captures clipboard history locally and makes recall immediate.

> Copy once. Remember it. Recall instantly.

## v0.1 foundation

- Native AppKit + SwiftUI application
- Menu-bar-only presence
- Global `⌥Space` recall shortcut
- Automatic text clipboard capture
- Up to 1,000 local entries
- URL / code / text classification
- Full-text filtering
- Pin / delete / clear-unpinned
- Direct paste back into the previous application
- Source application bundle metadata
- Local persistence under `~/Library/Application Support/Wonderland/Nexil/`
- No network dependency

## Security boundary

Nexil is intentionally **not Crystal**. Clipboard history is short-lived local memory. Promotion into Crystal will be an explicit future action rather than automatic ingestion.

The current prototype stores encoded history locally to establish the application boundary. Encryption-at-rest, secret detection, application exclusion policies, lifecycle retention, structured object storage, and evidence are subsequent gates before production use.

## Build

```bash
cd nexil
swift build -c release
.build/release/Nexil
```

For direct paste, macOS may require Accessibility permission for Nexil under **System Settings → Privacy & Security → Accessibility**.

## Design target

Nexil should remain keyboard-first, local-first, private, fast, and small. The menu bar is the persistent anchor; the recall surface is the primary interaction.
