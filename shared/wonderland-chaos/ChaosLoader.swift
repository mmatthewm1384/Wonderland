import Foundation

enum ChaosLoader {
    static let defaultPath =
        "\(NSHomeDirectory())/Wonderland/vault/chaos/visual-chaos-contract.json"

    static func load() -> ChaosContract? {
        let env = ProcessInfo.processInfo.environment["WL_CHAOS_CONTRACT"]
        let path = env ?? defaultPath

        guard
            FileManager.default.fileExists(atPath: path),
            let data = FileManager.default.contents(atPath: path)
        else {
            return nil
        }

        return try? JSONDecoder().decode(ChaosContract.self, from: data)
    }
}
