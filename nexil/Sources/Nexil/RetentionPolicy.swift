import Foundation

struct RetentionPolicy {
    var normalLifetime: TimeInterval = 30 * 24 * 60 * 60
    var maximumObjects = 1000

    func expired(_ object: ClipboardObject, now: Date = .now) -> Bool {
        guard !object.pinned else { return false }
        return now.timeIntervalSince(object.createdAt) > normalLifetime
    }
}
