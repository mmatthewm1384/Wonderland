import AVFoundation
import Foundation

public actor SynapseAudioEngine {
    private let audioEngine = AVAudioEngine()
    private let inputNode: AVAudioInputNode
    private var isRunning = false
    private var recordedBuffers: [AVAudioPCMBuffer] = []
    private var recordedFormat: AVAudioFormat?

    public init() {
        self.inputNode = self.audioEngine.inputNode
    }

    public func configureSession() throws {
        #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
    }

    public func startRecording(bufferHandler: @escaping @Sendable (AVAudioPCMBuffer, AVAudioTime) -> Void) throws {
        guard !self.isRunning else { return }
        try self.configureSession()

        self.recordedBuffers.removeAll()
        let format = self.inputNode.outputFormat(forBus: 0)
        self.recordedFormat = format

        self.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            Task {
                await self?.appendBuffer(buffer)
            }
            bufferHandler(buffer, time)
        }

        self.audioEngine.prepare()
        try self.audioEngine.start()
        self.isRunning = true
    }

    private func appendBuffer(_ buffer: AVAudioPCMBuffer) {
        self.recordedBuffers.append(buffer)
    }

    public func stopRecording() throws -> Data? {
        guard self.isRunning else { return nil }
        self.inputNode.removeTap(onBus: 0)
        self.audioEngine.stop()
        self.isRunning = false

        guard let format = recordedFormat, !recordedBuffers.isEmpty else { return nil }
        return try self.convertBuffersToWAV(self.recordedBuffers, format: format)
    }

    private func convertBuffersToWAV(_ buffers: [AVAudioPCMBuffer], format: AVAudioFormat) throws -> Data {
        _ = buffers.reduce(0) { $0 + Int($1.frameLength) }
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".wav")

        let audioFile = try AVAudioFile(
            forWriting: tempFile,
            settings: format.settings,
            commonFormat: format.commonFormat,
            interleaved: format.isInterleaved
        )

        for buffer in buffers {
            try audioFile.write(from: buffer)
        }

        let data = try Data(contentsOf: tempFile)
        try? FileManager.default.removeItem(at: tempFile)
        return data
    }
}
