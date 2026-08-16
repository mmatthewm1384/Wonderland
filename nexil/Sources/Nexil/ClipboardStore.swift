import AppKit
import Combine
import CryptoKit
import Foundation

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var clips: [ClipboardObject] = []

    private let limit = 1000
    private let url: URL
    private let secretPolicy = SecretPolicy()

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = base.appendingPathComponent("Wonderland/Nexil", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.url = directory.appendingPathComponent("history.json")
        load()
    }

    func capture(pasteboard: NSPasteboard) {
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        guard !normalized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard secretPolicy.evaluate(normalized) == .store else { return }
        guard clips.first?.text != normalized else { return }

        let bytes = Data(normalized.utf8)
        let object = ClipboardObject(
            id: UUID(),
            createdAt: Date(),
            kind: classify(normalized),
            text: normalized,
            sourceBundleID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
            byteCount: bytes.count,
            sha256: SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined(),
            pinned: false
        )
        clips.insert(object, at: 0)
        enforceLimit()
        save()
    }

    func delete(_ clip: ClipboardObject) {
        clips.removeAll { $0.id == clip.id }
        save()
    }

    func togglePin(_ clip: ClipboardObject) {
        guard let index = clips.firstIndex(of: clip) else { return }
        clips[index].pinned.toggle()
        sort()
        save()
    }

    func clearUnpinned() {
        clips.removeAll { !$0.pinned }
        save()
    }

    private func classify(_ text: String) -> ClipboardObject.Kind {
        if text.hasPrefix("http://") || text.hasPrefix("https://") { return .url }
        if text.contains("\n") && (text.contains("{") || text.contains(";") || text.contains("func ") || text.contains("#!/")) { return .code }
        return .text
    }

    private func enforceLimit() {
        guard clips.count > limit else { return }
        let pinned = clips.filter(\.pinned)
        let unpinned = clips.filter { !$0.pinned }.prefix(max(0, limit - pinned.count))
        clips = Array(pinned) + Array(unpinned)
        sort()
    }

    private func sort() {
        clips.sort {
            if $0.pinned != $1.pinned { return $0.pinned && !$1.pinned }
            return $0.createdAt > $1.createdAt
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ClipboardObject].self, from: data) else { return }
        clips = decoded
        sort()
        enforceLimit()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(clips) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }
}
