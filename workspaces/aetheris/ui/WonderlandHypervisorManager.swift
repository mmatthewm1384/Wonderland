import Foundation
import Virtualization

public class WonderlandHypervisorManager {
    private var virtualMachine: VZVirtualMachine?

    public func spawnMicroVM() async throws -> Bool {
        let config = VZVirtualMachineConfiguration()

        // Configure CPU and Memory constraints for Apple Silicon M4
        config.cpuCount = 2
        config.memorySize = 256 * 1024 * 1024 // 256 MB

        // Point to the compiled kernel and initrd paths
        let kernelPath = NSHomeDirectory() + "/Developer/projects/aetheris/data/kernel/vmlinux"
        let initrdPath = NSHomeDirectory() + "/Developer/projects/aetheris/data/kernel/initrd"

        // Fixed: VZLinuxBootLoader (capital L) and bootLoader (capital L)
        let bootloader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: kernelPath))
        bootloader.initialRamdiskURL = URL(fileURLWithPath: initrdPath)
        bootloader.commandLine = "console=hvc0 root=/dev/vda rw"
        config.bootLoader = bootloader

        try config.validate()

        let vm = VZVirtualMachine(configuration: config)
        self.virtualMachine = vm

        return await withCheckedContinuation { continuation in
            vm.start { result in
                switch result {
                case .success():
                    continuation.resume(returning: true)
                case let .failure(error):
                    print("Failed to spawn micro-VM: \(error.localizedDescription)")
                    continuation.resume(returning: false)
                }
            }
        }
    }

    public func terminateMicroVM() async {
        guard let vm = virtualMachine, vm.state == .running else { return }
        try? await vm.stop()
        self.virtualMachine = nil
    }
}
