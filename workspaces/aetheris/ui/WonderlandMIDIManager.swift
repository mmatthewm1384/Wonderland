// /Users/wonderland/Developer/projects/aetheris/ui/WonderlandMIDIManager.swift

import Combine
import CoreMIDI
import Foundation

public class WonderlandMIDIManager: ObservableObject {
    @Published public var isConnected: Bool = false
    @Published public var deviceName: String = "Virtual MIDI In"
    @Published public var availableInputs: [String] = ["Virtual MIDI In", "Aetheris Controller Hub"]
    @Published public var selectedInput: String = "Virtual MIDI In"
    @Published public var lastReceivedNote: (UInt8, UInt8)? = nil // (noteNumber, velocity)
    @Published public var lastReceivedCC: (UInt8, UInt8)? = nil // (controllerNumber, value)
    @Published public var knobMappings: [UInt8: String] = [
        1: "Filter Cutoff",
        2: "Resonance",
        7: "Volume",
        10: "Pan"
    ]

    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()

    public init() {
        self.setupMIDI()
    }

    public func setupMIDI() {
        let clientName = "WonderlandMIDIClient" as CFString
        _ = MIDIClientCreate(clientName, nil, nil, &self.midiClient)

        let portName = "WonderlandInputPort" as CFString
        _ = MIDIInputPortCreate(self.midiClient, portName, midiReceiveCallback, Unmanaged.passUnretained(self).toOpaque(), &self.inputPort)

        self.isConnected = true
    }

    public func toggleConnection() {
        self.isConnected.toggle()
        self.deviceName = self.isConnected ? "Virtual MIDI In" : "Disconnected"
    }

    public func simulateNoteTrigger(note: UInt8, velocity: UInt8) {
        self.lastReceivedNote = (note, velocity)
    }

    public func connectToDevice(_ name: String) {
        self.selectedInput = name
        self.deviceName = name
        self.isConnected = true
    }

    public func disconnect() {
        self.isConnected = false
    }
}

private func midiReceiveCallback(pktlist: UnsafePointer<MIDIPacketList>, readProcRefCon: UnsafeMutableRawPointer?, srcConnRefCon _: UnsafeMutableRawPointer?) {
    guard let refCon = readProcRefCon else { return }
    let manager = Unmanaged<WonderlandMIDIManager>.fromOpaque(refCon).takeUnretainedValue()
    let packetList = pktlist.pointee
    var packet = packetList.packet

    for _ in 0 ..< packetList.numPackets {
        let length = Int(packet.length)
        if length >= 3 {
            let status = packet.data.0
            let data1 = packet.data.1
            let data2 = packet.data.2

            DispatchQueue.main.async {
                if (status & 0xF0) == 0x90 {
                    manager.lastReceivedNote = (data1, data2)
                } else if (status & 0xF0) == 0xB0 {
                    manager.lastReceivedCC = (data1, data2)
                }
            }
        }
        packet = withUnsafePointer(to: &packet) { ptr in
            ptr.withMemoryRebound(to: MIDIPacket.self, capacity: 1) { nextPtr in
                MIDIPacketNext(nextPtr)
            }
        }.pointee
    }
}
