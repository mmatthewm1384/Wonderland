import AppKit
import Foundation

enum ChaosTypedConfirmation {
    static func requirePhrase(title: String, message: String, phrase: String) async -> Bool {
        await MainActor.run {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = "\(message)\n\nType \(phrase) to continue."
            alert.alertStyle = .critical

            let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
            input.placeholderString = phrase
            alert.accessoryView = input

            alert.addButton(withTitle: "Authorize")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            return response == .alertFirstButtonReturn &&
                input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) == phrase
        }
    }
}
