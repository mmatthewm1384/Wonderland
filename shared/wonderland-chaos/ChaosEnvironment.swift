import Foundation
import Combine
import AppKit

final class ChaosEnvironment: ObservableObject {
    @Published var contract: ChaosContract?

    private var timer: Timer?

    init() {
        reload()

        timer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            self?.reload()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadNotification),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(reloadNotification),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @objc
    private func reloadNotification() {
        reload()
    }

    func reload() {
        contract = ChaosLoader.load()
    }

    func config(for appName: String) -> ChaosContract.AppConfig? {
        contract?.apps[appName]
    }
}
