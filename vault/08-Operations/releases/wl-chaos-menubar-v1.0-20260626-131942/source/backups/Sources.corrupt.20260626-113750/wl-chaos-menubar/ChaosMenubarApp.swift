cd ~/Workshop/apps/macos/wl-chaos-menubar || exit 1

cp Sources/wl-chaos-menubar/ChaosMenubarApp.swift \
  backups/ChaosMenubarApp.swift.bad-monolith.$(date +%Y%m%d-%H%M%S)

cat > Sources/wl-chaos-menubar/ChaosMenubarApp.swift <<'EOF'
import AppKit
import Foundation

@main
final class ChaosMenubarApp: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    private func refresh() {
        let state = ChaosStatus.load()
        item.button?.title = state.chaos_active ? "☄︎ CHAOS" : "☄︎"
        item.menu = buildMenu(state)
    }

    private func buildMenu(_ state: ChaosStatus) -> NSMenu {
        let menu = NSMenu()

        menu.addItem(disabled("☄︎ Mode: \(state.mode)"))
        menu.addItem(disabled("Aether: \(state.aether)"))
        menu.addItem(disabled("Watchdog: \(state.watchdog)"))
        menu.addItem(disabled("Countdown: \(state.countdownSummary)"))
        menu.addItem(.separator())

        menu.addItem(disabled("Last Check-In: \(state.last_checkin)"))
        menu.addItem(disabled("Last Activity: \(state.last_activity)"))
        menu.addItem(disabled("Escalation Window: \(state.escalation_window)"))
        menu.addItem(.separator())

        menu.addItem(disabled("Contract"))
        menu.addItem(disabled("chaos_active: \(state.chaos_active)"))
        menu.addItem(disabled("rings: \(state.rings)"))
        menu.addItem(disabled("rotation: \(state.rotation)"))
        menu.addItem(disabled("intensity: \(state.intensity)"))
        menu.addItem(disabled("particles: \(state.particles)"))
        menu.addItem(disabled("living_ratio: \(state.living_ratio)"))
        menu.addItem(.separator())

        menu.addItem(action("Check In", #selector(checkIn)))
        menu.addItem(action("Reset Chaos", #selector(resetChaos)))
        menu.addItem(action("Panic", #selector(panic)))
        menu.addItem(.separator())

        menu.addItem(action("Open Chaos Folder", #selector(openChaosFolder)))
        menu.addItem(action("Open Audit Log", #selector(openAuditLog)))

        let advanced = NSMenuItem(title: "Advanced", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        submenu.addItem(action("Verify Lease", #selector(verifyLease)))
        submenu.addItem(action("Verify Providers", #selector(verifyProviders)))
        submenu.addItem(action("Open Policy", #selector(openPolicy)))
        submenu.addItem(action("Open Gate Folder", #selector(openGateFolder)))
        submenu.addItem(action("Reload Menubar", #selector(reloadMenubar)))
        advanced.submenu = submenu
        menu.addItem(advanced)

        menu.addItem(.separator())
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

    @objc private func checkIn() {
        _ = ChaosCommand.run(["checkin"])
        refresh()
    }

    @objc private func resetChaos() {
        _ = ChaosCommand.run(["reset"])
        refresh()
    }

    @objc private func panic() {
        _ = ChaosCommand.run(["panic"])
        refresh()
    }

    @objc private func verifyLease() {
        _ = ChaosCommand.run(["doctor"])
        refresh()
    }

    @objc private func verifyProviders() {
        _ = ChaosCommand.run(["status"])
        refresh()
    }

    @objc private func openChaosFolder() {
        NSWorkspace.shared.open(URL(fileURLWithPath: Paths.chaosVault))
    }

    @objc private func openAuditLog() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "\(Paths.chaosVault)/menubar-actions.log"))
    }

    @objc private func openPolicy() {
        NSWorkspace.shared.open(URL(fileURLWithPath: Paths.operatorGate))
    }

    @objc private func openGateFolder() {
        NSWorkspace.shared.open(URL(fileURLWithPath: Paths.operatorGate))
    }

    @objc private func reloadMenubar() {
        refresh()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
EOF
