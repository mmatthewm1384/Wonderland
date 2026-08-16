import Foundation

struct ClipboardObject: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case text
        case url
        case code
        case image
        case file
    }

    let id: UUID
    let createdAt: Date
    let kind: Kind
    let text: String?
    let sourceBundleID: String?
    let byteCount: Int
    let sha256: String
    var pinned: Bool

    var searchableText: String { text ?? "" }
}
