import Foundation

struct ClipboardObject: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case text, richText, url, code, image, file
    }

    let id: UUID
    let createdAt: Date
    let kind: Kind
    let text: String?
    let payload: Data?
    let sourceBundleID: String?
    let sourceApplicationName: String?
    let byteCount: Int
    let sha256: String
    let uti: String?
    let fileURLs: [String]
    var pinned: Bool

    var searchableText: String {
        [text ?? "", sourceBundleID ?? "", sourceApplicationName ?? "", fileURLs.joined(separator: " ")].joined(separator: " ")
    }

    var previewText: String {
        if let text, !text.isEmpty { return text }
        if !fileURLs.isEmpty { return fileURLs.joined(separator: "\n") }
        if kind == .image { return "Image" }
        return kind.rawValue.capitalized
    }
}
