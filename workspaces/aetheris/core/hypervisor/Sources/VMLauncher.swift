/// 1. Create a dedicated serial queue for the virtual machine lifecycle
let vmQueue = DispatchQueue(label: "com.aetheris.vmQueue")

// 2. Initialize VZVirtualMachine bound to this queue
print("[AETHERIS-SWIFT] Initializing VZVirtualMachine instance...")
let virtualMachine = VZVirtualMachine(configuration: vmConfig, queue: vmQueue)
print("[AETHERIS-SWIFT] VZVirtualMachine instance created. Starting boot sequence...")

let semaphore = DispatchSemaphore(value: 0)
var bootSuccess = false
var startupError: Error?

// 3. Dispatch start to the VM's designated queue
vmQueue.async {
    virtualMachine.start { result in
        switch result {
        case .success():
            print("[AETHERIS-SWIFT] Micro-VM boot sequence successfully initiated.")
            bootSuccess = true
        case let .failure(error):
            print("[AETHERIS-SWIFT] Error starting virtual machine: \(error)")
            startupError = error
        }
        semaphore.signal()
    }
}

let timeout: TimeInterval = 15.0
let startDateTime = Date()
while semaphore.wait(timeout: .now() + 0.05) == .timedOut {
    if Date().timeIntervalSince(startDateTime) > timeout {
        print("[AETHERIS-SWIFT] Error: VM start operation timed out after \(timeout) seconds.")
        return nil
    }
    CFRunLoopRunInMode(CFRunLoopMode.defaultMode, 0.01, true)
}

if !bootSuccess {
    return nil
}
