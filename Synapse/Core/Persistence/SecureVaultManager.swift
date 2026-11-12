import Foundation

public actor SecureVaultManager {
    private let fileManager = FileManager.default
    private let vaultDirectoryName = "SynapseSecureVault"

    private var vaultURL: URL {
        let paths = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(self.vaultDirectoryName, isDirectory: true)
    }

    public init() {}

    private func createVaultDirectoryIfNeeded() {
        if !self.fileManager.fileExists(atPath: self.vaultURL.path) {
            try? self.fileManager.createDirectory(at: self.vaultURL, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.protectionKey: FileProtectionType.complete
            ])
        }
    }

    public func saveSession(sessionId: String, audioData: Data, metadataJSON: String) throws {
        self.createVaultDirectoryIfNeeded()

        let sessionFolder = self.vaultURL.appendingPathComponent(sessionId, isDirectory: true)
        try self.fileManager.createDirectory(at: sessionFolder, withIntermediateDirectories: true, attributes: [
            FileAttributeKey.protectionKey: FileProtectionType.complete
        ])

        let audioURL = sessionFolder.appendingPathComponent("audio.wav")
        let metadataURL = sessionFolder.appendingPathComponent("metadata.json")

        try audioData.write(to: audioURL, options: [.atomic, .completeFileProtection])
        try metadataJSON.write(to: metadataURL, atomically: true, encoding: .utf8)
    }

    public func loadSession(sessionId: String) throws -> (audioData: Data, metadata: String)? {
        let sessionFolder = self.vaultURL.appendingPathComponent(sessionId, isDirectory: true)
        let audioURL = sessionFolder.appendingPathComponent("audio.wav")
        let metadataURL = sessionFolder.appendingPathComponent("metadata.json")

        guard self.fileManager.fileExists(atPath: audioURL.path),
              self.fileManager.fileExists(atPath: metadataURL.path)
        else {
            return nil
        }

        let audioData = try Data(contentsOf: audioURL)
        let metadata = try String(contentsOf: metadataURL, encoding: .utf8)

        return (audioData, metadata)
    }

    public func listSessions() throws -> [String] {
        self.createVaultDirectoryIfNeeded()
        let contents = try fileManager.contentsOfDirectory(
            at: self.vaultURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        return contents.filter(\.hasDirectoryPath).map(\.lastPathComponent)
    }
}
