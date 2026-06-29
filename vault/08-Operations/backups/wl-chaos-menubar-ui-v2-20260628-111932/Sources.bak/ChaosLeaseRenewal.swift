import Foundation

enum ChaosLeaseRenewal {
    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")

    static func renew(mode: String, ttlMinutes: Int) -> Bool {
        let script = root.appendingPathComponent("bin/wl-chaos-lease")

        let process = Process()
        process.executableURL = script
        process.arguments = [
            "--mode", mode,
            "--ttl-minutes", String(ttlMinutes)
        ]

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
