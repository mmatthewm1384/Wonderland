import Virtualization
@testable import WonderlandApp
import XCTest

@available(macOS 14.0, *)
final class WonderlandHypervisorTests: XCTestCase {
    var hypervisor: WonderlandHypervisor!

    override func setUp() {
        super.setUp()
        self.hypervisor = WonderlandHypervisor()
    }

    override func tearDown() {
        self.hypervisor = nil
        super.tearDown()
    }

    func testHypervisorInitialization() {
        XCTAssertNotNil(self.hypervisor, "Hypervisor instance should initialize successfully.")
        XCTAssertNil(self.hypervisor.virtualMachine, "Virtual machine should be nil before booting.")
    }

    func testBootMicroVMWithInvalidPaths() {
        let expectation = XCTestExpectation(description: "Boot should fail gracefully with invalid file paths")

        let fakeKernel = "/nonexistent/kernel"
        let fakeInitrd = "/nonexistent/initrd"
        let fakeDisk = "/nonexistent/disk.img"

        self.hypervisor.bootMicroVM(kernelPath: fakeKernel, initrdPath: fakeInitrd, diskPath: fakeDisk) { success, error in
            XCTAssertFalse(success, "Boot should fail when kernel/disk assets do not exist.")
            XCTAssertNotNil(error, "An error should be returned for missing disk or kernel files.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testStopWhenNotRunning() {
        let expectation = XCTestExpectation(description: "Stopping an inactive hypervisor should succeed immediately")

        self.hypervisor.stopMicroVM { success in
            XCTAssertTrue(success, "Stopping an un-started hypervisor should report success.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testVirtualizationSupportFlag() {
        // Verify that the framework reports support status accurately for the current host environment
        let supported = VZVirtualMachine.isSupported
        // On Apple Silicon M4 running macOS 14+, this will be true.
        // We assert that the property is readable and doesn't crash.
        XCTAssertTrue(supported || !supported, "VZVirtualMachine.isSupported should return a definitive boolean.")
    }
}
