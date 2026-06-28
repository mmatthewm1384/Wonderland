import Foundation

enum ChaosDebug {
    static let enabled = false

    static let root = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Wonderland")
    static let logURL = root.appendingPathComponent("vault/chaos/menubar-debug.log")

    static func log(_ message: String) {
        guard enabled else { return }

        let line = "\(ISO8601DateFormatter().string(from: Date())) \(message)\n"

        do {
            try FileManager.default.createDirectory(
                at: logURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            if FileManager.default.fileExists(atPath: logURL.path) {
                let handle = try FileHandle(forWritingTo: logURL)
                try handle.seekToEnd()
                try handle.write(contentsOf: Data(line.utf8))
                try handle.close()
            } else {
                try Data(line.utf8).write(to: logURL, options: .atomic)
            }
        } catch {
            NSLog("ChaosDebug failed: \(error.localizedDescription)")
        }
    }
}
