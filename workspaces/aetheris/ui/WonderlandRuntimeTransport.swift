import Combine
import Foundation

@MainActor
public final class WonderlandRuntimeTransport: ObservableObject {
    private let ipcClient: AetherisIPCClient

    public init(ipcClient: AetherisIPCClient) {
        self.ipcClient = ipcClient
    }

    public convenience init() {
        self.init(ipcClient: AetherisIPCClient())
    }

    public var isConnected: Bool {
        self.ipcClient.isConnected
    }

    public var lastPayload: String {
        self.ipcClient.lastPayload
    }

    public var connectionError: String? {
        self.ipcClient.connectionError
    }

    public func send(_ payload: String) {
        self.ipcClient.sendCommand(payload)
    }

    public func send(action: String, target: String?) {
        var command: [String: String] = [
            "action": action
        ]

        if let target {
            command["target"] = target
        }

        guard
            let data = try? JSONSerialization.data(withJSONObject: command),
            let payload = String(data: data, encoding: .utf8)
        else {
            return
        }

        self.send(payload)
    }

    public func disconnect() {
        self.ipcClient.disconnect()
    }
}
