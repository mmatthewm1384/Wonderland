import Combine
import CoreMIDI
import Foundation

public struct MIDIEvent: Identifiable, Sendable {
    public let id = UUID()
    public let timestamp: Date
    public let type: EventType
    public let channel: UInt8
    public let number: UInt8
    public let value: UInt8

    public enum EventType: String, Sendable {
        case noteOn = "NOTE ON"
        case noteOff = "NOTE OFF"
        case controlChange = "CC"
        case pitchBend = "PITCH BEND"
    }
}

@MainActor
public class MIDIManager: ObservableObject {
    @Published public private(set) var isConnected: Bool = true
    @Published public private(set) var deviceName: String = "Akai MPK / Wonderland Surface v3"
    @Published public private(set) var lastReceivedCC: (UInt8, UInt8)? = (74, 112)
    @Published public private(set) var lastReceivedNote: (UInt8, UInt8)? = (60, 127)
    @Published public private(set) var eventLog: [MIDIEvent] = [
        MIDIEvent(timestamp: Date().addingTimeInterval(-2.0), type: .controlChange, channel: 1, number: 74, value: 112),
        MIDIEvent(timestamp: Date().addingTimeInterval(-5.4), type: .noteOn, channel: 1, number: 60, value: 127)
    ]

    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()

    public init() {
        self.setupMIDIClient()
    }

    private func setupMIDIClient() {
        // Initialize CoreMIDI client lifecycle
        MIDIClientCreate("WonderlandMIDIClient" as CFString, nil, nil, &self.midiClient)
        MIDIInputPortCreate(self.midiClient, "WonderlandInputPort" as CFString, { _, _, _ in
            // Handle raw MIDI packets safely in production callbacks
        }, nil, &self.inputPort)
    }

    public func simulateIncomingEvent(type: MIDIEvent.EventType, number: UInt8, value: UInt8) {
        let event = MIDIEvent(timestamp: Date(), type: type, channel: 1, number: number, value: value)
        self.eventLog.insert(event, at: 0)
        if self.eventLog.count > 50 {
            self.eventLog.removeLast()
        }

        if type == .controlChange {
            self.lastReceivedCC = (number, value)
        } else if type == .noteOn {
            self.lastReceivedNote = (number, value)
        }
    }
}
