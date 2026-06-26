import Foundation

@discardableResult
func shell(_ command: String) -> String {
    let p = Process()
    let out = Pipe()
    let err = Pipe()

    p.executableURL = URL(fileURLWithPath: "/bin/bash")
    p.arguments = ["-lc", command]
    p.standardOutput = out
    p.standardError = err

    do {
        try p.run()
        p.waitUntilExit()
    } catch {
        return "ERROR: \(error.localizedDescription)"
    }

    let stdout = String(data: out.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let stderr = String(data: err.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    let text = (stdout + stderr).trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? "OK" : text
}

func nowText() -> String {
    let f = DateFormatter()
    f.dateFormat = "h:mm:ss a"
    return f.string(from: Date())
}
