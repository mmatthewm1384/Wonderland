import AppKit
import Foundation

@MainActor
final class ClipboardMonitor {
    private let store: NexilStore
    private let writeGuard: ClipboardWriteGuard
    private var timer: Timer?
    private var changeCount: Int

    init(
        store: NexilStore,
        writeGuard: ClipboardWriteGuard
    ) {
        self.store = store
        self.writeGuard = writeGuard
        self.changeCount = NSPasteboard.general.changeCount
    }

    func start() {
        guard timer == nil else { return }

        timer = Timer.scheduledTimer(
            withTimeInterval: 0.35,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }

                let pasteboard = NSPasteboard.general
                let currentChangeCount = pasteboard.changeCount

                guard currentChangeCount != self.changeCount else {
                    return
                }

                self.changeCount = currentChangeCount

                if self.writeGuard.shouldSuppress(
                    changeCount: currentChangeCount
                ) {
                    return
                }

                self.store.capture(pasteboard: pasteboard)
            }
        }

        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
