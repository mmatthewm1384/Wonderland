import AppKit
import Foundation

extension ChaosMenubarApp {
    @objc func openDashboardV2(_ sender: NSMenuItem) {
        let candidates = [
            "/Users/wonderland/Applications/Wonderland Control Center.app",
            "\(NSHomeDirectory())/Applications/Wonderland Control Center.app",
            "\(NSHomeDirectory())/Wonderland/Applications/Wonderland Control Center.app"
        ]

        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
                statusText = "Dashboard opened"
                refreshMenu()
                return
            }
        }

        NSWorkspace.shared.open(URL(fileURLWithPath: "\(NSHomeDirectory())/Wonderland"))
        statusText = "Dashboard app not found"
        refreshMenu()
    }

    @objc func openLogsV2(_ sender: NSMenuItem) {
        let root = URL(fileURLWithPath: "\(NSHomeDirectory())/Wonderland")
        let intentDir = root.appendingPathComponent("vault/05-Registry/control-center")
        let intentFile = intentDir.appendingPathComponent("open-intent.json")

        try? FileManager.default.createDirectory(
            at: intentDir,
            withIntermediateDirectories: true
        )

        let payload: [String: Any] = [
            "schema": "wonderland.control-center.open-intent.v1",
            "target": "chaos.logs",
            "source": "wl-chaos-menubar",
            "logs": [
                root.appendingPathComponent("vault/chaos/menubar.launchd.out.log").path,
                root.appendingPathComponent("vault/chaos/menubar.launchd.err.log").path,
                root.appendingPathComponent("vault/chaos/scheduler-audit.jsonl").path,
                root.appendingPathComponent("vault/chaos/audit.jsonl").path
            ],
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]

        if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) {
            try? data.write(to: intentFile, options: [.atomic])
        }

        let candidates = [
            "/Users/wonderland/Applications/Wonderland Control Center.app",
            "\(NSHomeDirectory())/Applications/Wonderland Control Center.app",
            "\(NSHomeDirectory())/Wonderland/Applications/Wonderland Control Center.app"
        ]

        for path in candidates {
            if FileManager.default.fileExists(atPath: path) {
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
                statusText = "Opening Chaos logs"
                refreshMenu()
                return
            }
        }

        NSWorkspace.shared.activateFileViewerSelecting([
            root.appendingPathComponent("vault/chaos/menubar.launchd.out.log")
        ])

        statusText = "Control Center not found"
        refreshMenu()
    }

    @objc func openChaosFolderV2(_ sender: NSMenuItem) {
        let url = URL(fileURLWithPath: "\(NSHomeDirectory())/Wonderland/vault/05-Registry/chaos")
        NSWorkspace.shared.open(url)
        statusText = "Chaos folder opened"
        refreshMenu()
    }
}
