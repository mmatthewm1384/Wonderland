import AppKit
import Foundation

final class ChaosMenubarApp: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var statusText = "Ready"

    func applicationDidFinishLaunching(_ notification: Notification) {
        ChaosDebug.log("APP_LAUNCH applicationDidFinishLaunching")
        refreshMenu()
        Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.refreshMenu()
        }
    }

    private func refreshMenu() {
        ChaosDebug.log("REFRESH_MENU")
        let state = ChaosStatus.load()

        if let button = statusItem.button {
            button.image = ChaosIcon.image(for: state)
            button.image?.isTemplate = false
            button.title = " WL"
        }

        statusItem.menu = buildMenu(state)
    }

    private func buildMenu(_ state: ChaosStatus) -> NSMenu {
        ChaosDebug.log("BUILD_MENU chaos_active=\(state.chaos_active) status=\(statusText)")
        let menu = NSMenu()

        let authority = ChaosAuthorityStatusReader.load()

        menu.addItem(disabled("◆ \(state.displayState)"))
        menu.addItem(disabled("\(state.healthMark) \(state.healthText)"))
        menu.addItem(disabled("Gate: \(statusText)"))
        menu.addItem(.separator())

        menu.addItem(disabled("Authority"))
        menu.addItem(disabled(authority.fingerprintLine))
        menu.addItem(disabled(authority.leaseLine))
        menu.addItem(disabled(authority.authLine))
        menu.addItem(disabled(ChaosControllerStatus.checkSync()))
        menu.addItem(.separator())

        menu.addItem(disabled("Watchdog: \(state.watchdog)"))
        menu.addItem(disabled("Aether: \(state.aether)"))
        menu.addItem(disabled("Escalation: \(state.countdownSummary)"))
        menu.addItem(.separator())

        let modelsMenuItem = NSMenuItem(title: "Chaos Models", action: nil, keyEquivalent: "")
        let modelsMenu = NSMenu()

        for model in ChaosModels.all {
            let lock = model.requiresHumanApproval ? " 🔐" : ""
            let item = NSMenuItem(
                title: "\(model.title) · risk \(model.riskLevel)\(lock)",
                action: #selector(runChaosModelFromMenu(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = model.id
            modelsMenu.addItem(item)
        }

        modelsMenuItem.submenu = modelsMenu
        menu.addItem(modelsMenuItem)

        menu.addItem(.separator())
        menu.addItem(action("Check In", #selector(checkIn)))

        if state.chaos_active {
            menu.addItem(action("Reset Chaos", #selector(resetChaos)))
            menu.addItem(action("Escalate Chaos", #selector(panic)))
        } else {
            menu.addItem(action("Activate Chaos", #selector(panic)))
        }
        menu.addItem(.separator())

        menu.addItem(action("Open Logs", #selector(openAuditLog)))
        menu.addItem(action("Open Chaos Folder", #selector(openChaosFolder)))

        let advanced = NSMenuItem(title: "Advanced", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        submenu.addItem(action("Verify Backend", #selector(verifyProviders)))
        submenu.addItem(action("Verify Lease", #selector(verifyLease)))
        submenu.addItem(action("Reload Menubar", #selector(reloadMenubar)))
        submenu.addItem(.separator())
        submenu.addItem(disabled("Last Check-In: \(state.last_checkin)"))
        submenu.addItem(disabled("Last Activity: \(state.last_activity)"))
        submenu.addItem(disabled("Escalation Window: \(state.escalation_window)"))
        submenu.addItem(.separator())
        submenu.addItem(disabled("chaos_active: \(state.chaos_active)"))
        submenu.addItem(disabled("rings: \(state.rings)"))
        submenu.addItem(disabled("rotation: \(state.rotation)"))
        submenu.addItem(disabled("intensity: \(state.intensity)"))
        submenu.addItem(disabled("particles: \(state.particles)"))
        submenu.addItem(disabled("living_ratio: \(state.living_ratio)"))
        submenu.addItem(.separator())
        submenu.addItem(action("Open Policy", #selector(openPolicy)))
        submenu.addItem(action("Open Gate Folder", #selector(openGateFolder)))
        advanced.submenu = submenu
        menu.addItem(advanced)

        menu.addItem(.separator())
        menu.addItem(disabled("Version: 1.1.0"))
        menu.addItem(disabled("Last: \(state.lastResult)"))
        menu.addItem(disabled("At: \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"))
        menu.addItem(action("Quit", #selector(quit)))

        return menu
    }

    private func disabled(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func action(_ title: String, _ selector: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: "")
        item.target = self
        return item
    }

    @objc private func runChaosModelFromMenu(_ sender: NSMenuItem) {
        ChaosDebug.log("MENU_MODEL_SELECTED representedObject=\(String(describing: sender.representedObject))")
        guard
            let modelID = sender.representedObject as? String,
            let model = ChaosModels.find(modelID)
        else {
            statusText = "Denied: unknown chaos model"
            refreshMenu()
            return
        }

        ChaosExecutionGate.run(
            model: model,
            setStatus: { [weak self] status in
                self?.statusText = status
                self?.refreshMenu()
            },
            execute: { [weak self] model in
                self?.executeChaosModel(model)
                self?.refreshMenu()
            }
        )
    }

    private func executeChaosModel(_ model: ChaosModel) {
        ChaosDebug.log("EXECUTE_MODEL id=\(model.id) command=\(model.command)")

        Task {
            let controllerOK = await ChaosControllerClient.execute(model: model)

            await MainActor.run {
                if controllerOK {
                    ChaosAudit.recordExecutionSource(model: model, source: "controller-api", success: true)
                    writeChaosState(
                        mode: model.id,
                        effect: "controller-api, command:\(model.command), risk:\(model.riskLevel), reversible:\(model.reversible)"
                    )
                    statusText = "Active via controller: \(model.id)"
                } else {
                    ChaosAudit.recordExecutionSource(model: model, source: "controller-api", success: false)
                    statusText = "Denied: controller execution failed"
                }

                refreshMenu()
            }
        }
    }

    private func writeChaosState(mode: String, effect: String) {
        ChaosDebug.log("WRITE_STATE mode=\(mode) effect=\(effect)")
        let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")
        let stateURL = root.appendingPathComponent("vault/chaos/menubar-state.json")

        let payload: [String: Any] = [
            "schema": "wonderland.chaos.menubar.state.v1",
            "mode": mode,
            "effect": effect,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            try FileManager.default.createDirectory(
                at: stateURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let data = try JSONSerialization.data(
                withJSONObject: payload,
                options: [.prettyPrinted, .sortedKeys]
            )

            try data.write(to: stateURL, options: .atomic)
            statusText = "Active: \(mode)"
        } catch {
            statusText = "Failed: \(error.localizedDescription)"
        }
    }

    @objc private func checkIn() {
        ChaosDebug.log("LEGACY_CHECKIN_SELECTED")
        _ = ChaosCommand.run(["checkin"])
        statusText = "Check-in recorded"
        refreshMenu()
    }

    @objc private func resetChaos() {
        ChaosDebug.log("LEGACY_RESET_SELECTED")
        guard let model = ChaosModels.find("recovery") else {
            statusText = "Denied: recovery model missing"
            refreshMenu()
            return
        }

        ChaosExecutionGate.run(
            model: model,
            setStatus: { [weak self] (status: String) in
                self?.statusText = status
                self?.refreshMenu()
            },
            execute: { [weak self] (model: ChaosModel) in
                self?.executeChaosModel(model)
                self?.refreshMenu()
            }
        )
    }

    @objc private func panic() {
        ChaosDebug.log("LEGACY_PANIC_SELECTED")
        let state = ChaosStatus.load()
        let modelID = state.chaos_active ? "storm" : "nudge"

        guard let model = ChaosModels.find(modelID) else {
            statusText = "Denied: \(modelID) model missing"
            refreshMenu()
            return
        }

        ChaosExecutionGate.run(
            model: model,
            setStatus: { [weak self] (status: String) in
                self?.statusText = status
                self?.refreshMenu()
            },
            execute: { [weak self] (model: ChaosModel) in
                self?.executeChaosModel(model)
                self?.refreshMenu()
            }
        )
    }

    @objc private func verifyProviders() {
        _ = ChaosCommand.run(["doctor"])
        statusText = "Backend verified"
        refreshMenu()
    }

    @objc private func verifyLease() {
        _ = ChaosCommand.run(["status"])
        statusText = "Lease checked"
        refreshMenu()
    }

    @objc private func openChaosFolder() {
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland/vault/chaos")
        NSWorkspace.shared.open(url)
    }

    @objc private func openAuditLog() {
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland/vault/chaos/menubar-audit.jsonl")
        NSWorkspace.shared.open(url)
    }

    @objc private func openPolicy() {
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland/vault/chaos")
        NSWorkspace.shared.open(url)
    }

    @objc private func openGateFolder() {
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland/vault/05-Registry/chaos")
        NSWorkspace.shared.open(url)
    }

    @objc private func reloadMenubar() {
        statusText = "Reloaded"
        refreshMenu()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

enum ChaosIcon {
    static func image(for state: ChaosStatus) -> NSImage {
        let size = NSSize(width: 22, height: 22)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()

        let mode = readMode()
        let color = colorForMode(mode: mode, active: state.chaos_active)

        let center = NSPoint(x: 11, y: 11)
        let diamond = NSBezierPath()
        diamond.move(to: NSPoint(x: center.x, y: 2.5))
        diamond.line(to: NSPoint(x: 19.5, y: center.y))
        diamond.line(to: NSPoint(x: center.x, y: 19.5))
        diamond.line(to: NSPoint(x: 2.5, y: center.y))
        diamond.close()

        color.withAlphaComponent(0.18).setFill()
        diamond.fill()

        color.setStroke()
        diamond.lineWidth = 1.5
        diamond.stroke()

        // Inner matrix rails
        for x in stride(from: 7.0, through: 15.0, by: 2.0) {
            let rail = NSBezierPath()
            rail.move(to: NSPoint(x: x, y: 6.0))
            rail.line(to: NSPoint(x: x, y: 16.0))
            rail.lineWidth = 0.65
            color.withAlphaComponent(0.75).setStroke()
            rail.stroke()
        }

        // Matrix ticks
        let ticks: [(Double, Double, Double)] = [
            (7, 8, 10), (7, 12, 14),
            (9, 6.8, 8.2), (9, 10.2, 12.1), (9, 14, 15.6),
            (11, 7.4, 9.4), (11, 11.1, 13.2), (11, 15, 16.2),
            (13, 6.8, 8.6), (13, 10.7, 11.9), (13, 13.8, 15.4),
            (15, 8.1, 9.9), (15, 12.2, 14.3)
        ]

        for (x, y1, y2) in ticks {
            let tick = NSBezierPath()
            tick.move(to: NSPoint(x: x, y: y1))
            tick.line(to: NSPoint(x: x, y: y2))
            tick.lineWidth = 1.1
            color.setStroke()
            tick.stroke()
        }

        // Center node
        color.withAlphaComponent(state.chaos_active ? 0.95 : 0.65).setFill()
        NSBezierPath(ovalIn: NSRect(x: 9.6, y: 9.6, width: 2.8, height: 2.8)).fill()

        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    private static func readMode() -> String {
        let url = URL(fileURLWithPath: NSHomeDirectory())
            .appendingPathComponent("Wonderland/vault/chaos/menubar-state.json")

        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let mode = json["mode"] as? String
        else {
            return "calm"
        }

        return mode
    }

    private static func colorForMode(mode: String, active: Bool) -> NSColor {
        switch mode {
        case "recovery":
            return NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.40, alpha: 1.0)
        case "blackout":
            return NSColor(calibratedRed: 1.0, green: 0.20, blue: 0.35, alpha: 1.0)
        case "cataclysm":
            return NSColor(calibratedRed: 1.0, green: 0.0, blue: 0.25, alpha: 1.0)
        case "storm":
            return NSColor(calibratedRed: 0.44, green: 0.0, blue: 1.0, alpha: 1.0)
        case "drift":
            return NSColor(calibratedRed: 0.30, green: 0.55, blue: 1.0, alpha: 1.0)
        case "nudge":
            return NSColor(calibratedRed: 0.0, green: 0.90, blue: 1.0, alpha: 1.0)
        default:
            return active
                ? NSColor(calibratedRed: 0.44, green: 0.0, blue: 1.0, alpha: 1.0)
                : NSColor(calibratedRed: 0.0, green: 0.90, blue: 1.0, alpha: 1.0)
        }
    }
}

