import Foundation
import libkern
import Virtualization

public class AetherisVMContext {
    let id: UUID
    let memorySizeMB: UInt64
    var virtualMachine: VZVirtualMachine?
    var serialPipeReadFd: Int32 = -1
    var serialPipeWriteFd: Int32 = -1
    var telemetrySource: DispatchSourceRead?
    let telemetryQueue = DispatchQueue(label: "org.aetheris.telemetry", qos: .utility)
    let vmQueue = DispatchQueue(label: "org.aetheris.vm", qos: .userInitiated)

    let inputPipe = Pipe()
    let outputPipe = Pipe()

    init(id: UUID, memorySizeMB: UInt64) {
        self.id = id
        self.memorySizeMB = memorySizeMB
        self.serialPipeReadFd = self.outputPipe.fileHandleForReading.fileDescriptor
        self.serialPipeWriteFd = self.inputPipe.fileHandleForWriting.fileDescriptor
    }

    func configureAndStart() throws {
        let configuration = VZVirtualMachineConfiguration()

        configuration.cpuCount = 2
        configuration.memorySize = self.memorySizeMB * 1024 * 1024
        configuration.platform = VZGenericPlatformConfiguration()

        let kernelPath = "/Users/wonderland/Developer/projects/aetheris/assets/vmlinuz"
        let initrdPath = "/Users/wonderland/Developer/projects/aetheris/assets/modloop-virt"

        guard FileManager.default.fileExists(atPath: kernelPath) else {
            throw NSError(domain: "AetherisVM", code: 1, userInfo: [NSLocalizedDescriptionKey: "Kernel not found at \(kernelPath)"])
        }

        let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: kernelPath))
        bootLoader.commandLine = "console=hvc0 console=ttyS0 root=/dev/vda rw"

        if FileManager.default.fileExists(atPath: initrdPath) {
            bootLoader.initialRamdiskURL = URL(fileURLWithPath: initrdPath)
        }
        configuration.bootLoader = bootLoader

        let serialConfiguration = VZVirtioConsoleDeviceConfiguration()
        let consolePort = VZVirtioConsolePortConfiguration()
        consolePort.name = "org.aetheris.serial.console"
        consolePort.attachment = VZFileHandleSerialPortAttachment(
            fileHandleForReading: self.inputPipe.fileHandleForReading,
            fileHandleForWriting: self.outputPipe.fileHandleForWriting
        )
        serialConfiguration.ports[0] = consolePort
        configuration.consoleDevices = [serialConfiguration]

        let rootFsPath = "/Users/wonderland/Developer/projects/aetheris/assets/rootfs.img"
        if FileManager.default.fileExists(atPath: rootFsPath) {
            let rootAttachment = try VZDiskImageStorageDeviceAttachment(
                url: URL(fileURLWithPath: rootFsPath),
                readOnly: false
            )
            configuration.storageDevices = [VZVirtioBlockDeviceConfiguration(attachment: rootAttachment)]
        }

        try configuration.validate()
        print("[AETHERIS-SWIFT] Configuration validated successfully.")

        let semaphore = DispatchSemaphore(value: 0)
        var startupError: Error?

        self.vmQueue.sync { [weak self] in
            guard let self else {
                semaphore.signal()
                return
            }

            let vm = VZVirtualMachine(configuration: configuration)
            self.virtualMachine = vm

            print("[AETHERIS-SWIFT] Initializing VZVirtualMachine instance...")
            vm.start { result in
                switch result {
                case .success():
                    print("[AETHERIS-SWIFT] Micro-VM boot sequence successfully initiated.")
                    self.startTelemetryStream()
                case let .failure(error):
                    startupError = error
                    print("[AETHERIS-SWIFT] Failed to start micro-VM: \(error.localizedDescription)")
                }
                semaphore.signal()
            }
        }

        _ = semaphore.wait(timeout: .now() + 10.0)
        if let error = startupError {
            throw error
        }
    }

    private func startTelemetryStream() {
        guard self.serialPipeReadFd >= 0 else { return }
        let flags = fcntl(serialPipeReadFd, F_GETFL)
        _ = fcntl(self.serialPipeReadFd, F_SETFL, flags | O_NONBLOCK)

        let source = DispatchSource.makeReadSource(fileDescriptor: self.serialPipeReadFd, queue: self.telemetryQueue)
        source.setEventHandler { [weak self] in
            var buffer = [UInt8](repeating: 0, count: 1024)
            let bytesRead = read(self?.serialPipeReadFd ?? -1, &buffer, buffer.count)
            if bytesRead > 0, let outputString = String(bytes: buffer[0 ..< bytesRead], encoding: .utf8) {
                print("[AETHERIS-GUEST] \(outputString)", terminator: "")
            }
        }
        source.resume()
        self.telemetrySource = source
    }

    func zeroizeAndShutdown() {
        guard let vm = virtualMachine else { return }
        let semaphore = DispatchSemaphore(value: 0)
        vm.stop { _ in semaphore.signal() }
        _ = semaphore.wait(timeout: .now() + 3.0)
    }
}

@_cdecl("spawn_ephemeral_vm")
public func spawn_ephemeral_vm(
    memoryMB: UInt64,
    outHandle: UnsafeMutablePointer<UnsafeMutableRawPointer?>
) -> Int32 {
    let vmId = UUID()
    let context = AetherisVMContext(id: vmId, memorySizeMB: memoryMB)

    do {
        try context.configureAndStart()
        outHandle.pointee = Unmanaged.passRetained(context).toOpaque()
        return 0
    } catch {
        print("[AETHERIS-SWIFT] VM spawn error: \(error)")
        return -1
    }
}

@_cdecl("aetheris_get_serial_read_fd")
public func aetheris_get_serial_read_fd(handle: UnsafeMutableRawPointer?) -> Int32 {
    guard let handle else { return -1 }
    return Unmanaged<AetherisVMContext>.fromOpaque(handle).takeUnretainedValue().serialPipeReadFd
}

@_cdecl("aetheris_write_serial_input")
public func aetheris_write_serial_input(handle: UnsafeMutableRawPointer?, dataPtr: UnsafePointer<UInt8>?, dataLen: Int) -> Int32 {
    guard let handle, let dataPtr, dataLen > 0 else { return -1 }
    let context = Unmanaged<AetherisVMContext>.fromOpaque(handle).takeUnretainedValue()
    return Int32(write(context.serialPipeWriteFd, dataPtr, dataLen))
}

@_cdecl("terminate_and_zeroize_vm")
public func terminate_and_zeroize_vm(handle: UnsafeMutableRawPointer?) -> Int32 {
    guard let handle else { return -1 }
    Unmanaged<AetherisVMContext>.fromOpaque(handle).takeRetainedValue().zeroizeAndShutdown()
    return 0
}
