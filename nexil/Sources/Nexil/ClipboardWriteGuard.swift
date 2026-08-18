import Foundation

@MainActor
final class ClipboardWriteGuard {
    private var pendingChangeCount: Int?

    func mark(changeCount: Int) {
        pendingChangeCount = changeCount
    }

    func shouldSuppress(changeCount: Int) -> Bool {
        guard let pendingChangeCount else {
            return false
        }

        guard pendingChangeCount == changeCount else {
            // The clipboard changed again after Nexil's intentional write.
            // That change belongs to the outside world and must be captured.
            self.pendingChangeCount = nil
            return false
        }

        self.pendingChangeCount = nil
        return true
    }

    func reset() {
        pendingChangeCount = nil
    }
}
