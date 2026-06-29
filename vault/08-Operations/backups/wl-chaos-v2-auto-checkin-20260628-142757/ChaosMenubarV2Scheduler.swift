import AppKit
import Foundation

extension ChaosMenubarApp {
    @objc func runScheduleNowV2(_ sender: NSMenuItem) {
        statusText = "Running schedule…"
        refreshMenu()

        DispatchQueue.global(qos: .utility).async {
            _ = Shell.run("/Users/wonderland/Wonderland/bin/wl-chaos-schedule-run", [])

            DispatchQueue.main.async {
                self.statusText = "Schedule checked"
                self.refreshMenu()
            }
        }
    }

    @objc func startSchedulerV2(_ sender: NSMenuItem) {
        statusText = "Starting scheduler…"
        refreshMenu()

        DispatchQueue.global(qos: .utility).async {
            _ = Shell.run("/Users/wonderland/Wonderland/bin/wl-chaos-schedule", ["start"])

            DispatchQueue.main.async {
                self.statusText = "Scheduler started"
                self.refreshMenu()
            }
        }
    }

    @objc func stopSchedulerV2(_ sender: NSMenuItem) {
        statusText = "Stopping scheduler…"
        refreshMenu()

        DispatchQueue.global(qos: .utility).async {
            _ = Shell.run("/Users/wonderland/Wonderland/bin/wl-chaos-schedule", ["stop"])

            DispatchQueue.main.async {
                self.statusText = "Scheduler stopped"
                self.refreshMenu()
            }
        }
    }

    @objc func pauseSchedulerV2(_ sender: NSMenuItem) {
        statusText = "Pausing scheduler…"
        refreshMenu()

        DispatchQueue.global(qos: .utility).async {
            _ = Shell.run("/Users/wonderland/Wonderland/bin/wl-chaos-schedule", ["pause"])

            DispatchQueue.main.async {
                self.statusText = "Scheduler paused"
                self.refreshMenu()
            }
        }
    }

    @objc func resumeSchedulerV2(_ sender: NSMenuItem) {
        statusText = "Resuming scheduler…"
        refreshMenu()

        DispatchQueue.global(qos: .utility).async {
            _ = Shell.run("/Users/wonderland/Wonderland/bin/wl-chaos-schedule", ["resume"])

            DispatchQueue.main.async {
                self.statusText = "Scheduler resumed"
                self.refreshMenu()
            }
        }
    }


}
