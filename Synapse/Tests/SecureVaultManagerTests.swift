@testable import Synapse
import XCTest

final class SecureVaultManagerTests: XCTestCase {
    func testVaultSaveLoadAndList() async throws {
        let vault = SecureVaultManager()
        let sessionId = "TestSession-\(UUID().uuidString)"
        let sampleAudioData = Data("MockAudioPCMBufferBytes".utf8)
        let sampleMetadata = "{\"sessionId\": \"\(sessionId)\", \"transcript\": \"Testing secure vault integration\"}"

        // Save session
        try await vault.saveSession(sessionId: sessionId, audioData: sampleAudioData, metadataJSON: sampleMetadata)

        // Load session
        let loaded = try await vault.loadSession(sessionId: sessionId)
        XCTAssertNotNil(loaded, "Loaded session should not be nil.")
        XCTAssertEqual(loaded?.audioData, sampleAudioData, "Audio data must match the saved buffer.")
        XCTAssertEqual(loaded?.metadata, sampleMetadata, "Metadata JSON must match.")

        // List sessions
        let sessions = try await vault.listSessions()
        XCTAssertTrue(sessions.contains(sessionId), "Session list must contain the newly saved session ID.")
    }
}
