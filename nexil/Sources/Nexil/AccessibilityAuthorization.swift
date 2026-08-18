import AppKit
import ApplicationServices
import Combine
import Foundation

@MainActor
final class AccessibilityAuthorization: ObservableObject {
    @Published private(set) var isTrusted: Bool

    init() {
        isTrusted = AXIsProcessTrusted()
    }

    func refresh() {
        isTrusted = AXIsProcessTrusted()
    }

    func request() {
        let options: NSDictionary = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ]

        isTrusted = AXIsProcessTrustedWithOptions(options)
    }

    func openSettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        ) else {
            return
        }

        NSWorkspace.shared.open(url)
    }
}
