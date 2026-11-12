// --- Wonderland Hypervisor Orchestration Layer ---
// Path: Sources/WonderlandUI/WonderlandHypervisor.swift

import Foundation
import Virtualization

@available(macOS 14.0, *)
public class WonderlandHypervisor: NSObject, VZVirtualMachineDelegate {
    public var virtualMachine: VZVirtualMachine?
    private var isRunning: Bool = false

    override public init() {
        super.init()
    }

    public func bootMicroVM(
        kernelPath: String,
        initrdPath: String,
        diskPath: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard VZVirtualMachine.isSupported else {
            let error = NSError(
                domain: "WonderlandHypervisor",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Virtualization.framework is not supported on this hardware configuration."]
            )
            completion(false, error)
            return
        }

        let cpuCount = max(1, min(4, ProcessInfo.processInfo.processorCount / 2))
        let memorySize = UInt64(256) * 1024 * 1024 // 256 MB optimized footprint

        // Configure Bootloader & Linux Kernel Parameters
        let bootloader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: kernelPath))
        bootloader.initialRamdiskURL = URL(fileURLWithPath: initrdPath)
        bootloader.commandLine = "console=hvc0 root=/dev/vda rw init=/sbin/init"

        let configuration = VZVirtualMachineConfiguration()
        configuration.bootLoader = bootloader
        configuration.cpuCount = cpuCount
        configuration.memorySize = memorySize

        // Configure Storage Attachment (Virtio Block)
        do {
            let diskAttachment = try VZDiskImageStorageDeviceAttachment(
                url: URL(fileURLWithPath: diskPath),
                readOnly: false
            )
            let diskDevice = VZVirtioBlockDeviceConfiguration(attachment: diskAttachment)
            configuration.storageDevices = [diskDevice]
        } catch {
            completion(false, error)
            return
        }

        // Configure Serial Console (Virtio Console Port)
        let consoleDevice = VZVirtioConsoleDeviceConfiguration()
        let consolePort = VZVirtioConsolePortConfiguration()
        let consoleAttachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: FileHandle.nullDevice,
            fileHandleForWriting: FileHandle.standardOutput
        )
        consolePort.attachment = consoleAttachment
        consoleDevice.ports[0] = consolePort
        configuration.consoleDevices = [consoleDevice]

        // Configure Network Device (NAT Network Attachment)
        let networkDevice = VZVirtioNetworkDeviceConfiguration()
        let natAttachment = VZNATNetworkDeviceAttachment()
        networkDevice.attachment = natAttachment
        configuration.networkDevices = [networkDevice]

        // Validate Configuration State
        do {
            try configuration.validate()
        } catch {
            completion(false, error)
            return
        }

        // Instantiate and Start Virtual Machine
        let vm = VZVirtualMachine(configuration: configuration)
        vm.delegate = self
        self.virtualMachine = vm

        vm.start { [weak self] result in
            switch result {
            case .success():
                self?.isRunning = true
                completion(true, nil)
            case let .failure(error):
                completion(false, error)
            }
        }
    }

    public func stopMicroVM(completion: @escaping (Bool) -> Void) {
        guard let vm = virtualMachine, isRunning else {
            completion(true)
            return
        }

        vm.stop { [weak self] error in
            let success = (error == nil)
            if success {
                self?.isRunning = false
                self?.virtualMachine = nil
            }
            completion(success)
        }
    }

    // MARK: - VZVirtualMachineDelegate

    public func virtualMachine(_: VZVirtualMachine, didStopWithError _: Error) {
        self.isRunning = false
        self.virtualMachine = nil
    }
}
