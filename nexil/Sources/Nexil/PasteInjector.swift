import AppKit
import CoreGraphics
import Foundation

@MainActor
final class PasteInjector {
    func paste() -> Bool {
        guard AXIsProcessTrusted() else {
            NSLog("Nexil: Accessibility permission is not granted")
            return false
        }

        guard let source = CGEventSource(stateID: .combinedSessionState) else {
            NSLog("Nexil: failed to create CGEventSource")
            return false
        }

        guard
            let keyDown = CGEvent(
                keyboardEventSource: source,
                virtualKey: 0x09,
                keyDown: true
            ),
            let keyUp = CGEvent(
                keyboardEventSource: source,
                virtualKey: 0x09,
                keyDown: false
            )
        else {
            NSLog("Nexil: failed to create paste events")
            return false
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cgSessionEventTap)
        keyUp.post(tap: .cgSessionEventTap)

        return true
    }
}
