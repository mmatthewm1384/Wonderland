import Foundation

enum Shell {
    struct Result {
        let exitCode: Int32
        let stdout: String
        let stderr: String
    }

    static func run(_ path: String, _ args: [String]) -> Result {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        do {
            try process.run()
            process.waitUntilExit()

            let out = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            let err = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

            return Result(exitCode: process.terminationStatus, stdout: out, stderr: err)
        } catch {
            return Result(exitCode: 127, stdout: "", stderr: String(describing: error))
        }
    }
}
