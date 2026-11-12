import Foundation
import Virtualization

final class VMRunner: NSObject, VZVirtualMachineDelegate {
    var virtualMachine: VZVirtualMachine?

    func boot() {
        let configuration = VZVirtualMachineConfiguration()
        configuration.cpuCount = 2
        configuration.memorySize = 512 * 1024 * 1024
        configuration.platform = VZGenericPlatformConfiguration()

        let kernelPath = "/Users/wonderland/Developer/projects/aetheris/assets/vmlinuz"
        let initrdPath = "/Users/wonderland/Developer/projects/aetheris/assets/modloop-virt"
        let rootFsPath = "/Users/wonderland/Developer/projects/aetheris/assets/rootfs.img"

        guard FileManager.default.fileExists(atPath: kernelPath) else {
            fputs("[SWIFT-RUNNER] Error: Kernel not found\n", stderr)
            exit(1)
        }

        let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: kernelPath))
        bootLoader.commandLine = "console=hvc0 console=ttyS0 root=/dev/vda rw"
        if FileManager.default.fileExists(atPath: initrdPath) {
            bootLoader.initialRamdiskURL = URL(fileURLWithPath: initrdPath)
        }
        configuration.bootLoader = bootLoader

        // Serial console routed directly to stdout/stdin of this runner process
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
            } catch {
                fputs("[SWIFT-RUNNER] Warning: Failed to attach rootfs: \(error)\n", stderr)
            }
        }

        do {
            try configuration.validate()
        } catch {
            fputs("[SWIFT-RUNNER] Configuration validation failed: \(error)\n", stderr)
            exit(1)
        }

        let vm = VZVirtualMachine(configuration: configuration)
        vm.delegate = self
        self.virtualMachine = vm

        print("[SWIFT-RUNNER] Starting VZVirtualMachine...")
        vm.start { result in
            switch result {
            case .success():
                print("[SWIFT-RUNNER] Micro-VM started successfully.")
            case let .failure(error):
                fputs("[SWIFT-RUNNER] Failed to start VM: \(error)\n", stderr)
                exit(1)
            }
        }
    }
}

let runner = VMRunner()
runner.boot()

// Keep the process alive
RunLoop.main.run()
