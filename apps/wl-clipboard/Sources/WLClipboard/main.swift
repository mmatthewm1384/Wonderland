import AppKit
import CryptoKit
import Foundation

struct ClipboardItem: Codable {
    let id: UUID
    let created: Date
    let text: String
}

final class ClipboardVault {
    private let dir: URL
    private let db: URL
    private let keyFile: URL
    private let maxItems = 25

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.dir = home.appendingPathComponent(".wonderland/clipboard", isDirectory: true)
        self.db = dir.appendingPathComponent("history.enc")
        self.keyFile = dir.appendingPathComponent("key.bin")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    private func key() throws -> SymmetricKey {
        if FileManager.default.fileExists(atPath: keyFile.path) {
            return SymmetricKey(data: try Data(contentsOf: keyFile))
        }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        try data.write(to: keyFile, options: [.atomic])
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: keyFile.path)
        return key
    }

    func loadHistory() -> [ClipboardItem] {
        do {
            guard FileManager.default.fileExists(atPath: db.path) else { return [] }
            let data = try Data(contentsOf: db)
            let box = try AES.GCM.SealedBox(combined: data)
            let clear = try AES.GCM.open(box, using: key())
            return try JSONDecoder().decode([ClipboardItem].self, from: clear)
        } catch {
            return []
        }
    }

    func saveHistory(_ items: [ClipboardItem]) throws {
        let data = try JSONEncoder().encode(items)
        let sealed = try AES.GCM.seal(data, using: key())
        guard let combined = sealed.combined else { throw NSError(domain: "seal", code: 1) }
        try combined.write(to: db, options: [.atomic])
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: db.path)
    }

    func add(_ text: String) throws {
        var items = loadHistory()
        items.removeAll { $0.text == text }
        items.insert(ClipboardItem(id: UUID(), created: Date(), text: text), at: 0)
        items = Array(items.prefix(maxItems))
        try saveHistory(items)
    }

    func wipe() {
        try? FileManager.default.removeItem(at: db)
    }

    var path: String { db.path }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let vault = ClipboardVault()
    var timer: Timer?
    var lastChangeCount = NSPasteboard.general.changeCount


    @MainActor
    func wlSetClipboardIcon(_ symbol: String = "doc.on.clipboard.fill") {
        statusItem.button?.title = ""

        guard let sf = NSImage(
            systemSymbolName: symbol,
            accessibilityDescription: "WL Clipboard"
        ) else {
            return
        }

        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size)

        img.lockFocus()

        let rect = NSRect(origin: .zero, size: size)

        sf.draw(
            in: rect,
            from: .zero,
            operation: .sourceOver,
            fraction: 1.0
        )

        NSColor(
            calibratedRed: 0.0,
            green: 229.0 / 255.0,
            blue: 255.0 / 255.0,
            alpha: 1.0
        ).set()

        rect.fill(using: .sourceAtop)

        img.unlockFocus()
        img.isTemplate = false

        statusItem.button?.image = img
        statusItem.button?.contentTintColor = nil
    }


    func applicationDidFinishLaunching(_ notification: Notification) {
        wlSetClipboardIcon()
        rebuildMenu()
        startClipboardWatcher()
    }


    func startClipboardWatcher() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkClipboard()
            }
        }
    }

    func checkClipboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        guard let text = pb.string(forType: .string), !text.isEmpty else { return }

        do {
            try vault.add(text)
            rebuildMenu()
            wlSetClipboardIcon("checkmark.circle.fill")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.wlSetClipboardIcon()
            }
        } catch {
            wlSetClipboardIcon("exclamationmark.triangle.fill")
        }
    }

    func rebuildMenu() {
        let menu = NSMenu()

        let saveItem = NSMenuItem(title: "Save Current Clipboard", action: #selector(saveClipboard), keyEquivalent: "s")
        saveItem.target = self
        menu.addItem(saveItem)
        menu.addItem(NSMenuItem.separator())

        let history = vault.loadHistory()
        if history.isEmpty {
            let empty = NSMenuItem(title: "No History Yet", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        } else {
            for item in history {
                let title = preview(item.text)
                let mi = NSMenuItem(title: title, action: #selector(restoreHistoryItem(_:)), keyEquivalent: "")
                mi.target = self
                mi.representedObject = item.text
                menu.addItem(mi)
            }
        }

        menu.addItem(NSMenuItem.separator())
        let refreshItem = NSMenuItem(title: "Refresh History", action: #selector(refresh), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        let wipeClipboardItem = NSMenuItem(title: "Wipe History", action: #selector(wipeClipboard), keyEquivalent: "w")
        wipeClipboardItem.target = self
        menu.addItem(wipeClipboardItem)
        let showPathItem = NSMenuItem(title: "Show Vault Path", action: #selector(showPath), keyEquivalent: "p")
        showPathItem.target = self
        menu.addItem(showPathItem)
        menu.addItem(NSMenuItem.separator())
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func preview(_ text: String) -> String {
        let clean = text.replacingOccurrences(of: "\n", with: " ")
        if clean.count <= 48 { return clean }
        return String(clean.prefix(48)) + "…"
    }

    @objc func saveClipboard() {
        guard let text = NSPasteboard.general.string(forType: .string), !text.isEmpty else {
            alert("Clipboard is empty or not text.")
            return
        }

        do {
            try vault.add(text)
            rebuildMenu()
            alert("Saved to encrypted history.")
        } catch {
            alert("Save failed: \(error.localizedDescription)")
        }
    }

    @objc func restoreHistoryItem(_ sender: NSMenuItem) {
        guard let text = sender.representedObject as? String else { return }
        NSPasteboard.general.clearContents()
        let ok = NSPasteboard.general.setString(text, forType: .string)
        if ok {
            wlSetClipboardIcon("checkmark.circle.fill")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.wlSetClipboardIcon()
            }
        } else {
            alert("Failed to restore clipboard.")
        }
    }

    @objc func refresh() {
        rebuildMenu()
    }

    @objc func wipeClipboard() {
        vault.wipe()
        rebuildMenu()
        alert("Encrypted history wiped.")
    }

    @objc func showPath() {
        alert(vault.path)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    func alert(_ message: String) {
        let a = NSAlert()
        a.messageText = "WL Clipboard"
        a.informativeText = message
        a.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
