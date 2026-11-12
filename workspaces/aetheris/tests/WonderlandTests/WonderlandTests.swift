@testable import WonderlandApp
import XCTest

final class WonderlandTests: XCTestCase {
    @MainActor
    func testViewModelInitialization() {
        let viewModel = WonderlandRuntimeViewModel()
        let throughput = viewModel.vectorThroughput
        XCTAssertGreaterThan(throughput, 0.0)
    }

    @MainActor
    func testMemoryCrystalTamperAndAuditFlow() {
        let viewModel = WonderlandRuntimeViewModel()
        let initialCrystals = viewModel.memoryCrystals
        guard let firstCrystal = initialCrystals.first else {
            XCTFail("No memory crystals found")
            return
        }

        viewModel.simulateTampering(for: firstCrystal.id)
        let tamperedCrystals = viewModel.memoryCrystals
        let target = tamperedCrystals.first { $0.id == firstCrystal.id }
        XCTAssertTrue(target?.isTampered == true)

        let logs = viewModel.telemetryLogs
        XCTAssertTrue(logs.contains { $0.source == "SECURITY-ADVISORY" || $0.message.contains("Tamper") })

        viewModel.restoreCrystal(for: firstCrystal.id)
        let restoredCrystals = viewModel.memoryCrystals
        XCTAssertFalse(restoredCrystals.first { $0.id == firstCrystal.id }?.isTampered ?? true)
    }

    @MainActor
    func testMicroVMLifecycle() {
        let viewModel = WonderlandRuntimeViewModel()
        viewModel.spawnVM()
        XCTAssertTrue(viewModel.isVMActive)

        viewModel.terminateVM()
        XCTAssertFalse(viewModel.isVMActive)
    }

    @MainActor
    func testLogExport() {
        let viewModel = WonderlandRuntimeViewModel()
        let exportURL = viewModel.exportLogs()
        XCTAssertNotNil(exportURL)
    }

    @MainActor
    func testLiveVectorSearchExecution() {
        let viewModel = WonderlandRuntimeViewModel()
        let initialLatencyCount = viewModel.latencyHistory.count

        viewModel.runLiveVectorSearch(queryVector: [0.1, 0.2, 0.3, 0.4], k: 3)

        XCTAssertFalse(viewModel.isQueryExecuting)
        XCTAssertGreaterThan(viewModel.latencyHistory.count, initialLatencyCount)
        XCTAssertFalse(viewModel.throughputHistory.isEmpty)
    }
}
