import Foundation

enum ChaosSchedulerControl {
    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")

    static func runScript(_ name: String, _ args: [String]) -> Bool {
        let script = root.appendingPathComponent("bin/\(name)")
        let process = Process()
        process.executableURL = script
        process.arguments = args

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }

    static func runNow() -> Bool {
        runScript("wl-chaos-schedule-run", [])
    }

    static func startExponential() -> Bool {
        runScript("wl-chaos-schedule", ["start", "--strategy", "exponential", "--hold-hours", "6"])
    }

    static func startHourly() -> Bool {
        runScript("wl-chaos-schedule", ["start", "--strategy", "hourly", "--hold-hours", "6"])
    }

    static func pause() -> Bool {
        runScript("wl-chaos-schedule", ["pause"])
    }

    static func resume() -> Bool {
        runScript("wl-chaos-schedule", ["resume"])
    }

    static func stop() -> Bool {
        runScript("wl-chaos-schedule", ["stop"])
    }

    static func repair() -> Bool {
        let a = runScript("wl-chaos-fingerprint", [])
        let b = runScript("wl-chaos-fingerprint-verify", [])
        let c = runScript("wl-chaos-verify", [])
        return a && b && c
    }
}
