import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private let store: ClipboardStore
    private var timer: Timer?
    private var changeCount: Int

    init(store: ClipboardStore) {
        self.store = store
        self.changeCount = NSPasteboard.general.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { [weak self] _ in
            guard let self else { return }
            let pasteboard = NSPasteboard.general
            guard pasteboard.changeCount != self.changeCount else { return }
            self.changeCount = pasteboard.changeCount
            self.store.capture(pasteboard: pasteboard)
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
