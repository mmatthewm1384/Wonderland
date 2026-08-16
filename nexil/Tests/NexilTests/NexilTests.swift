import Foundation
import Testing
@testable import Nexil

@Test("secret policy rejects common secrets")
func secretPolicyRejectsSecrets() {
    let policy = SecretPolicy()
    #expect(policy.evaluate("-----BEGIN PRIVATE KEY-----") == .reject)
    #expect(policy.evaluate("ghp_123456789012345678901234") == .reject)
    #expect(policy.evaluate("AKIA1234567890ABCDEF") == .reject)
    #expect(policy.evaluate("ordinary clipboard text") == .store)
}

@Test("retention preserves pinned objects")
func retentionPreservesPinnedObjects() {
    let policy = RetentionPolicy(normalLifetime: 60, maximumObjects: 1000)
    let old = ClipboardObject(id: UUID(), createdAt: Date(timeIntervalSinceNow: -120), kind: .text, text: "old", payload: nil, sourceBundleID: nil, sourceApplicationName: nil, byteCount: 3, sha256: "old", uti: nil, fileURLs: [], pinned: false)
    let pinned = ClipboardObject(id: UUID(), createdAt: Date(timeIntervalSinceNow: -120), kind: .text, text: "pinned", payload: nil, sourceBundleID: nil, sourceApplicationName: nil, byteCount: 6, sha256: "pinned", uti: nil, fileURLs: [], pinned: true)
    #expect(policy.expired(old))
    #expect(!policy.expired(pinned))
}

@Test("clipboard object preview is deterministic")
func clipboardObjectPreview() {
    let text = ClipboardObject(id: UUID(), createdAt: .now, kind: .text, text: "hello", payload: nil, sourceBundleID: nil, sourceApplicationName: nil, byteCount: 5, sha256: "x", uti: nil, fileURLs: [], pinned: false)
    let file = ClipboardObject(id: UUID(), createdAt: .now, kind: .file, text: nil, payload: nil, sourceBundleID: nil, sourceApplicationName: nil, byteCount: 0, sha256: "y", uti: nil, fileURLs: ["/tmp/example.txt"], pinned: false)
    #expect(text.previewText == "hello")
    #expect(file.previewText == "/tmp/example.txt")
}
