import AppKit
import Combine
import CryptoKit
import Foundation

@MainActor
final class NexilStore: ObservableObject {
    @Published private(set) var objects: [ClipboardObject] = []

    private let limit = 1000
    private let fileURL: URL
    private let keyURL: URL
    private let secretPolicy = SecretPolicy()
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    private let key: SymmetricKey

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Wonderland/Nexil", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: base.path)
        fileURL = base.appendingPathComponent("objects.nexil", isDirectory: false)
        keyURL = base.appendingPathComponent("store.key", isDirectory: false)
        key = Self.loadOrCreateKey(at: keyURL)
        load()
    }

    func capture(pasteboard: NSPasteboard) {
        guard let text = pasteboard.string(forType: .string), !text.isEmpty else { return }
        let normalized = text.replacingOccurrences(of: "\r\n", with: "\n")
        guard !normalized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard secretPolicy.evaluate(normalized) == .store else { return }
        guard objects.first?.text != normalized else { return }

        let bytes = Data(normalized.utf8)
        let object = ClipboardObject(
            id: UUID(), createdAt: Date(), kind: classify(normalized), text: normalized,
            sourceBundleID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
            byteCount: bytes.count,
            sha256: SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined(),
            pinned: false
        )
        objects.insert(object, at: 0)
        enforceLimit()
        save()
    }

    func delete(_ object: ClipboardObject) {
        objects.removeAll { $0.id == object.id }
        save()
    }

    func togglePin(_ object: ClipboardObject) {
        guard let index = objects.firstIndex(of: object) else { return }
        objects[index].pinned.toggle()
        sort(); save()
    }

    func clearUnpinned() {
        objects.removeAll { !$0.pinned }
        save()
    }

    func search(_ query: String) -> [ClipboardObject] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return objects }
        return objects.filter {
            $0.searchableText.lowercased().contains(q) ||
            $0.kind.rawValue.contains(q) ||
            ($0.sourceBundleID?.lowercased().contains(q) ?? false)
        }
    }

    private func classify(_ text: String) -> ClipboardObject.Kind {
        if URL(string: text)?.scheme != nil { return .url }
        if text.contains("\n") && (text.contains("{") || text.contains(";") || text.contains("func ") || text.contains("#!/")) { return .code }
        return .text
    }

    private func enforceLimit() {
        guard objects.count > limit else { return }
        let pinned = objects.filter(\.pinned)
        let unpinned = objects.filter { !$0.pinned }.prefix(max(0, limit - pinned.count))
        objects = Array(pinned) + Array(unpinned)
        sort()
    }

    private func sort() {
        objects.sort {
            if $0.pinned != $1.pinned { return $0.pinned && !$1.pinned }
            return $0.createdAt > $1.createdAt
        }
    }

    private func load() {
        guard let sealed = try? Data(contentsOf: fileURL),
              let plaintext = try? AES.GCM.open(AES.GCM.SealedBox(combined: sealed), using: key),
              let decoded = try? jsonDecoder.decode([ClipboardObject].self, from: plaintext) else { return }
        objects = decoded
        sort(); enforceLimit()
    }

    private func save() {
        guard let plaintext = try? jsonEncoder.encode(objects),
              let sealed = try? AES.GCM.seal(plaintext, using: key).combined else { return }
        try? sealed.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    private static func loadOrCreateKey(at url: URL) -> SymmetricKey {
        if let data = try? Data(contentsOf: url), data.count == 32 { return SymmetricKey(data: data) }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        try? data.write(to: url, options: [.atomic, .completeFileProtection])
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: url.path)
        return key
    }
}
