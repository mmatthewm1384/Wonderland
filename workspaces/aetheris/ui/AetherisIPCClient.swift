import Combine
import Darwin
import Foundation

@MainActor
public class AetherisIPCClient: ObservableObject {
    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var lastPayload: String = ""
    @Published public private(set) var connectionError: String? = nil

    private nonisolated let socketPath = NSHomeDirectory() + "/Library/Caches/wonderland/wonderland.sock"
    private nonisolated let queue = DispatchQueue(label: "com.wonderland.aetheris.ipc.client", qos: .userInitiated)

    private var clientSocket: Int32 = -1
    private var isRunning: Bool = false

    public init() {
        self.startListening()
    }

    public func startListening() {
        guard !self.isRunning else { return }
        self.isRunning = true
        let path = self.socketPath

        self.queue.async { [weak self] in
            while let self, Task.isCancelled == false {
                let running = DispatchQueue.main.sync { self.isRunning }
                guard running else { break }

                let sock = socket(AF_UNIX, SOCK_STREAM, 0)
                guard sock >= 0 else {
                    let errStr = String(cString: strerror(errno))
                    Task { @MainActor in self.connectionError = "Failed to create socket: \(errStr)" }
                    Thread.sleep(forTimeInterval: 3.0)
                    continue
                }

                var addr = sockaddr_un()
                addr.sun_family = sa_family_t(AF_UNIX)

                let maxLen = MemoryLayout.size(ofValue: addr.sun_path)
                let pathBytes = path.utf8.map { Int8($0) }
                guard pathBytes.count < maxLen else {
                    Task { @MainActor in self.connectionError = "Socket path too long" }
                    close(sock)
                    break
                }

                withUnsafeMutablePointer(to: &addr.sun_path) { ptr in
                    ptr.withMemoryRebound(to: Int8.self, capacity: maxLen) { dest in
                        for (i, byte) in pathBytes.enumerated() {
                            dest[i] = byte
                        }
                        dest[pathBytes.count] = 0
                    }
                }

                #if os(macOS)
                    addr.sun_len = __uint8_t(MemoryLayout<sockaddr_un>.size)
                #endif

                let addrLen = socklen_t(MemoryLayout<sockaddr_un>.size)
                let connectResult = withUnsafePointer(to: &addr) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockAddrPtr in
                        connect(sock, sockAddrPtr, addrLen)
                    }
                }

                if connectResult < 0 {
                    let errStr = String(cString: strerror(errno))
                    close(sock)
                    Task { @MainActor in
                        self.isConnected = false
                        self.connectionError = "Connection failed: \(errStr)"
                    }
                    Thread.sleep(forTimeInterval: 3.0)
                    continue
                }

                DispatchQueue.main.sync {
                    self.clientSocket = sock
                }

                Task { @MainActor in
                    self.isConnected = true
                    self.connectionError = nil
                }

                // Read loop
                var buffer = [UInt8](repeating: 0, count: 65536)
                var connected = true
                while connected {
                    let runningCheck = DispatchQueue.main.sync { self.isRunning }
                    guard runningCheck else {
                        connected = false
                        break
                    }

                    let bytesRead = recv(sock, &buffer, buffer.count, 0)
                    if bytesRead <= 0 {
                        connected = false
                        break
                    }

                    let data = Data(bytes: buffer, count: Int(bytesRead))
                    if let text = String(data: data, encoding: .utf8) {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            Task { @MainActor in
                                self.lastPayload = trimmed
                            }
                        }
                    }
                }

                close(sock)
                DispatchQueue.main.sync {
                    self.clientSocket = -1
                }

                Task { @MainActor in
                    self.isConnected = false
                }
                Thread.sleep(forTimeInterval: 3.0)
            }
        }
    }

    public func sendCommand(_ payload: String) {
        guard self.clientSocket >= 0, self.isConnected else { return }
        let message = payload + "\n"
        message.withCString { ptr in
            _ = write(self.clientSocket, ptr, strlen(ptr))
        }
    }

    public func disconnect() {
        self.isRunning = false
        if self.clientSocket >= 0 {
            close(self.clientSocket)
            self.clientSocket = -1
        }
        self.isConnected = false
    }
}
