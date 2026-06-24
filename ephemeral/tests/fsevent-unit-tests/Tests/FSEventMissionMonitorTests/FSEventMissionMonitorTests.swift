import XCTest
@testable import FSEventMissionMonitor

final class FSEventMissionMonitorTests: XCTestCase {

    var mockPEP: MockPEP!
    var spyLogger: SpyAetherLogger!
    var missionContext: MissionContext!

    override func setUp() {
        super.setUp()
        mockPEP = MockPEP()
        spyLogger = SpyAetherLogger()
        missionContext = MissionContext(
            missionId: "test-mission-001",
            intent: ["mission_id": "test-mission-001", "watch_paths": ["/tmp"]],
            startTime: Date()
        )
    }

    override func tearDown() {
        mockPEP = nil
        spyLogger = nil
        missionContext = nil
        super.tearDown()
    }

    final class MockPEP: FSEventPEP {
        var shouldSucceed = true
        var verifyCallCount = 0

        func verify(missionContext: MissionContext) throws {
            verifyCallCount += 1
            if !shouldSucceed {
                throw SlamError.invalidMissionIntent
            }
        }
    }

    final class SpyAetherLogger: AetherLogger {
        var loggedMessages: [String] = []

        func log(_ message: String) {
            loggedMessages.append(message)
        }
    }

    func testInit_SetsCorrectInitialState() {
        let monitor = FSEventMissionMonitor(missionContext: missionContext, pep: mockPEP, logger: spyLogger)
        XCTAssertFalse(monitor.isStreamActive)
        XCTAssertEqual(mockPEP.verifyCallCount, 0)
        XCTAssertTrue(spyLogger.loggedMessages.isEmpty)
    }

    func testStart_CallsPEPExactlyOnce() throws {
        let monitor = FSEventMissionMonitor(missionContext: missionContext, pep: mockPEP, logger: spyLogger)
        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)
        XCTAssertEqual(mockPEP.verifyCallCount, 1)
        monitor.stop()
    }

    func testStop_IsIdempotent() throws {
        let monitor = FSEventMissionMonitor(missionContext: missionContext, pep: mockPEP, logger: spyLogger)
        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)
        monitor.stop()
        monitor.stop()
        XCTAssertFalse(monitor.isStreamActive)
    }
}
