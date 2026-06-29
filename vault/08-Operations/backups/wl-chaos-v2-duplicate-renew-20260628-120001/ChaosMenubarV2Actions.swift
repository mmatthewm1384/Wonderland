import AppKit
import Foundation

extension ChaosMenubarApp {
    @objc func renewLease12hV2(_ sender: NSMenuItem) {
        statusText = "Renewing 12h lease…"
        refreshMenu()

        DispatchQueue.global(qos: .utility).async {
            _ = Shell.run("/Users/wonderland/Wonderland/tools/chaos/create-lease.py", [
                "--mode", "calm",
                "--scope", "chaos",
                "--ttl-minutes", "720"
            ])

            DispatchQueue.main.async {
                self.statusText = "Lease renewed"
                self.refreshMenu()
            }
        }
    }
}
