import Foundation
import Virtualization

// Disable standard output/error buffering for immediate log streaming
setvbuf(stdout, nil, _IONBF, 0)
setvbuf(stderr, nil, _IONBF, 0)

final class VMRunner: NSObject, VZVirtualMachineDelegate {
    var virtualMachine: VZVirtualMachine?

    func boot() {
        print("[SWIFT-RUNNER] Initializing VM configuration...")
        let configuration = VZVirtualMachineConfiguration()
        configuration.cpuCount = 2
        configuration.memorySize = 512 * 1024 * 1024
        configuration.platform = VZGenericPlatformConfiguration()

        let kernelPath = "/Users/wonderland/Developer/projects/aetheris/assets/Image"
        let initrdPath = "/Users/wonderland/Developer/projects/aetheris/assets/modloop-virt"
        let rootFsPath = "/Users/wonderland/Developer/projects/aetheris/assets/rootfs.img"

        guard FileManager.default.fileExists(atPath: kernelPath) else {
            fputs("[SWIFT-RUNNER] Error: Kernel not found at \(kernelPath)\n", stderr)
            exit(1)
        }

        let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: kernelPath))
        bootLoader.commandLine = "console=hvc0 console=ttyS0 root=/dev/vda rw"
        if FileManager.default.fileExists(atPath: initrdPath) {
            bootLoader.initialRamdiskURL = URL(fileURLWithPath: initrdPath)
            print("[SWIFT-RUNNER] Attached initial ramdisk: \(initrdPath)")
        }
        configuration.bootLoader = bootLoader

        let serialConfiguration = VZVirtioConsoleDeviceConfiguration()
        let consolePort = VZVirtioConsolePortConfiguration()
        consolePort.name = "org.aetheris.serial.console"
        consolePort.attachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: FileHandle.standardInput,
            fileHandleForWriting: FileHandle.standardOutput
        )
        serialConfiguration.ports[0] = consolePort
        configuration.consoleDevices = [serialConfiguration]

        if FileManager.default.fileExists(atPath: rootFsPath) {
            do {
                let attachment = try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: rootFsPath), readOnly: false)
                configuration.storageDevices = [VZVirtioBlockDeviceConfiguration(attachment: attachment)]
                print("[SWIFT-RUNNER] Attached root filesystem: \(rootFsPath)")
            } catch {
                fputs("[SWIFT-RUNNER] Warning: Failed to attach rootfs: \(error)\n", stderr)
            }
        }

        do {
            try configuration.validate()
            print("[SWIFT-RUNNER] Configuration validated successfully.")
        } catch {
            fputs("[SWIFT-RUNNER] Configuration validation failed: \(error)\n", stderr)
            exit(1)
        }

        let vm = VZVirtualMachine(configuration: configuration)
        vm.delegate = self
        self.virtualMachine = vm

        print("[SWIFT-RUNNER] Starting VZVirtualMachine instance...")
        vm.start { result in
            switch result {
            case .success():
                print("[SWIFT-RUNNER] Micro-VM boot sequence successfully initiated.")
            case let .failure(error):
                fputs("[SWIFT-RUNNER] Failed to start VM: \(error)\n", stderr)
                exit(1)
            }
        }
    }
}

print("[SWIFT-RUNNER] Process started. Booting VM runner...")
let runner = VMRunner()
runner.boot()
RunLoop.main.run()
