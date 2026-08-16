import AppKit
import Combine
import CryptoKit
import Foundation
import Security

@MainActor
final class NexilStore: ObservableObject {
    @Published private(set) var objects: [ClipboardObject] = []

    private let retention = RetentionPolicy()
    private let fileURL: URL
    private let keyAccount = "com.wonderland.nexil.store-key.v1"
    private let secretPolicy = SecretPolicy()
    private let exclusionPolicy = ExclusionPolicy()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let key: SymmetricKey

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Wonderland/Nexil", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        try? FileManager.default.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: base.path)
        fileURL = base.appendingPathComponent("objects.nexil")
        key = Self.loadOrCreateKey(account: keyAccount)
        load()
        purgeExpired()
    }

    func capture(pasteboard: NSPasteboard) {
        guard exclusionPolicy.allowsCapture() else { return }
        let source = NSWorkspace.shared.frontmostApplication

        if let text = pasteboard.string(forType: .string) {
            captureText(text, pasteboard: pasteboard, source: source)
            return
        }

        if let image = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
            captureBinary(kind: .image, payload: image, text: nil, uti: NSPasteboard.PasteboardType.png.rawValue, source: source)
            return
        }

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            let paths = urls.map(\.path)
            captureBinary(kind: .file, payload: nil, text: paths.joined(separator: "\n"), uti: NSPasteboard.PasteboardType.fileURL.rawValue, fileURLs: paths, source: source)
        }
    }

    func delete(_ object: ClipboardObject) { objects.removeAll { $0.id == object.id }; save() }

    func togglePin(_ object: ClipboardObject) {
        guard let index = objects.firstIndex(of: object) else { return }
        objects[index].pinned.toggle(); sort(); save()
    }

    func clearUnpinned() { objects.removeAll { !$0.pinned }; save() }

    func search(_ query: String) -> [ClipboardObject] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return objects }
        return objects.filter { object in
            object.searchableText.lowercased().contains(q) || object.kind.rawValue.lowercased().contains(q)
        }
    }

    func purgeExpired() {
        let before = objects.count
        objects.removeAll { retention.expired($0) }
        enforceLimit()
        if objects.count != before { save() }
    }

    private func captureText(_ rawText: String, pasteboard: NSPasteboard, source: NSRunningApplication?) {
        let normalized = rawText.replacingOccurrences(of: "\r\n", with: "\n")
        guard !normalized.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard secretPolicy.evaluate(normalized) == .store else { return }

        let rtf = pasteboard.data(forType: .rtf)
        let kind: ClipboardObject.Kind = rtf == nil ? classify(normalized) : .richText
        captureBinary(kind: kind, payload: rtf ?? Data(normalized.utf8), text: normalized,
                      uti: rtf == nil ? NSPasteboard.PasteboardType.string.rawValue : NSPasteboard.PasteboardType.rtf.rawValue,
                      source: source)
    }

    private func captureBinary(kind: ClipboardObject.Kind, payload: Data?, text: String?, uti: String?, fileURLs: [String] = [], source: NSRunningApplication?) {
        let hashInput = payload ?? Data((text ?? fileURLs.joined(separator: "\n")).utf8)
        let sha = SHA256.hash(data: hashInput).map { String(format: "%02x", $0) }.joined()
        guard !objects.contains(where: { $0.sha256 == sha }) else { return }

        let object = ClipboardObject(
            id: UUID(), createdAt: .now, kind: kind, text: text, payload: payload,
            sourceBundleID: source?.bundleIdentifier, sourceApplicationName: source?.localizedName,
            byteCount: hashInput.count, sha256: sha, uti: uti, fileURLs: fileURLs, pinned: false
        )
        objects.insert(object, at: 0)
        enforceLimit(); save()
    }

    private func classify(_ text: String) -> ClipboardObject.Kind {
        if URL(string: text)?.scheme != nil { return .url }
        if text.contains("\n") && (text.contains("{") || text.contains(";") || text.contains("func ") || text.contains("#!/") || text.contains("import ")) { return .code }
        return .text
    }

    private func enforceLimit() {
        guard objects.count > retention.maximumObjects else { return }
        let pinned = objects.filter(\.pinned)
        let unpinned = objects.filter { !$0.pinned }.prefix(max(0, retention.maximumObjects - pinned.count))
        objects = Array(pinned) + Array(unpinned); sort()
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
              let decoded = try? decoder.decode([ClipboardObject].self, from: plaintext) else { return }
        objects = decoded; sort(); enforceLimit()
    }

    private func save() {
        guard let plaintext = try? encoder.encode(objects),
              let sealed = try? AES.GCM.seal(plaintext, using: key).combined else { return }
        try? sealed.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    private static func loadOrCreateKey(account: String) -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Wonderland.Nexil",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
           let data = result as? Data, data.count == 32 { return SymmetricKey(data: data) }

        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        let add: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "Wonderland.Nexil",
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        _ = SecItemAdd(add as CFDictionary, nil)
        return key
    }
}
