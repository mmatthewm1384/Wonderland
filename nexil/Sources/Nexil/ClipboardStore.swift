import AppKit
import Combine
import Foundation

struct Clip: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    let type: String
    let text: String
    let sourceBundleID: String?
    var pinned: Bool
}

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var clips: [Clip] = []

    private let limit = 1000
    private let url: URL

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
        guard clips.first?.text != normalized else { return }

        let clip = Clip(
            id: UUID(),
            createdAt: Date(),
            type: classify(normalized),
            text: normalized,
            sourceBundleID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
            pinned: false
        )
        clips.insert(clip, at: 0)
        if clips.count > limit {
            clips = Array(clips.prefix(limit))
        }
        save()
    }

    func delete(_ clip: Clip) {
        clips.removeAll { $0.id == clip.id }
        save()
    }

    func togglePin(_ clip: Clip) {
        guard let index = clips.firstIndex(of: clip) else { return }
        clips[index].pinned.toggle()
        clips.sort { lhs, rhs in
            if lhs.pinned != rhs.pinned { return lhs.pinned && !rhs.pinned }
            return lhs.createdAt > rhs.createdAt
        }
        save()
    }

    func clearUnpinned() {
        clips.removeAll { !$0.pinned }
        save()
    }

    private func classify(_ text: String) -> String {
        if text.hasPrefix("http://") || text.hasPrefix("https://") { return "URL" }
        if text.contains("\n") && (text.contains("{") || text.contains(";") || text.contains("func ") || text.contains("#!/")) { return "Code" }
        return "Text"
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Clip].self, from: data) else { return }
        clips = decoded.sorted { lhs, rhs in
            if lhs.pinned != rhs.pinned { return lhs.pinned && !rhs.pinned }
            return lhs.createdAt > rhs.createdAt
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(clips) else { return }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
    }
}
