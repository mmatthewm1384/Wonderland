// FSEventMissionMonitorTests.swift
// Comprehensive XCTest suite for Wonderland FSEventMissionMonitor
// Add this file to your test target in Xcode (or compile with swift test if using Swift Package).
// Tests focus on pure Swift logic, state machine, error handling, PEP injection, timeout, and lifecycle.
// Real FSEventStream behavior is better covered by integration tests with temp directories.

import XCTest
@testable import FSEventMissionMonitor   // Adjust module name to match your target

// MARK: - Test Doubles (Mocks / Spies)

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

// MARK: - Test Suite

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

    // MARK: - Initialization & State Tests

    func testInit_SetsCorrectInitialState() {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        XCTAssertFalse(monitor.isStreamActive)
        XCTAssertEqual(mockPEP.verifyCallCount, 0)
        XCTAssertTrue(spyLogger.loggedMessages.isEmpty)
    }

    // MARK: - PEP & Path Validation Tests

    func testStart_CallsPEPExactlyOnce() throws {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        // Use a path that exists
        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)

        XCTAssertEqual(mockPEP.verifyCallCount, 1)
        monitor.stop()
    }

    func testStart_FailsWhenPEPRejects() {
        mockPEP.shouldSucceed = false

        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        XCTAssertThrowsError(try monitor.start(paths: [NSTemporaryDirectory()])) { error in
            XCTAssertTrue(error is SlamError)
            if case .invalidMissionIntent = error as? SlamError {
                // Expected
            } else {
                XCTFail("Expected invalidMissionIntent error")
            }
        }
    }

    func testStart_FailsOnInvalidPath() {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let badPath = "/this/path/does/not/exist/123456789"

        XCTAssertThrowsError(try monitor.start(paths: [badPath])) { error in
            XCTAssertTrue(error is SlamError)
            if case .pathValidationFailed = error as? SlamError {
                // Expected
            } else {
                XCTFail("Expected pathValidationFailed error")
            }
        }
    }

    func testStart_FailsWhenAlreadyActive() throws {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)

        XCTAssertThrowsError(try monitor.start(paths: [tempDir])) { error in
            XCTAssertTrue(error is SlamError)
            if case .streamAlreadyActive = error as? SlamError {
                // Expected
            } else {
                XCTFail("Expected streamAlreadyActive error")
            }
        }

        monitor.stop()
    }

    // MARK: - Lifecycle & State Tests

    func testStart_SetsActiveState() throws {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)

        XCTAssertTrue(monitor.isStreamActive)
        monitor.stop()
        XCTAssertFalse(monitor.isStreamActive)
    }

    func testStop_IsIdempotent() throws {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)

        monitor.stop()
        monitor.stop() // Should not crash or throw

        XCTAssertFalse(monitor.isStreamActive)
    }

    // MARK: - Logging / Aether Spy Tests

    func testStart_LogsStartMessage() throws {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)

        XCTAssertTrue(spyLogger.loggedMessages.contains { $0.contains("FSEvent stream started") })
        monitor.stop()
    }

    func testStop_LogsStopMessage() throws {
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)
        monitor.stop(reason: "test-stop")

        XCTAssertTrue(spyLogger.loggedMessages.contains { $0.contains("FSEvent stream stopped") && $0.contains("test-stop") })
    }

    // MARK: - Timeout Behavior (using short timeout for test speed)

    func testTimeout_StopsStreamAfterDuration() throws {
        let shortTimeout: TimeInterval = 0.2
        let monitor = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: shortTimeout
        )

        let tempDir = NSTemporaryDirectory()
        try monitor.start(paths: [tempDir], latency: 0.01)

        // Wait longer than timeout
        let expectation = expectation(description: "timeout should stop the stream")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(monitor.isStreamActive)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Deinit Safety

    func testDeinit_StopsStream() throws {
        var monitor: FSEventMissionMonitor? = FSEventMissionMonitor(
            missionContext: missionContext,
            pep: mockPEP,
            logger: spyLogger,
            missionTimeout: 5.0
        )

        let tempDir = NSTemporaryDirectory()
        try monitor?.start(paths: [tempDir], latency: 0.01)

        XCTAssertTrue(monitor?.isStreamActive == true)

        monitor = nil   // Trigger deinit

        // Give deinit time to run
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        // Note: In real tests with run loops this is more reliable; here we just verify no crash.
    }
}
