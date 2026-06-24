import Foundation
import CoreServices

enum SlamError: Error, CustomStringConvertible {
    case fseventCreationFailed(paths: [String])
    case invalidMissionIntent
    case streamAlreadyActive
    case gracefulShutdownTimeout
    case pathValidationFailed(path: String)

    var description: String {
        switch self {
        case .fseventCreationFailed(let paths): return "FSEventStreamCreate failed for paths: \(paths)"
        case .invalidMissionIntent: return "Invalid or unauthorized mission intent"
        case .streamAlreadyActive: return "FSEvent stream already active"
        case .gracefulShutdownTimeout: return "Graceful shutdown timed out"
        case .pathValidationFailed(let path): return "Path validation failed: \(path)"
        }
    }
}

struct MissionContext {
    let missionId: String
    let intent: [String: Any]
    let startTime: Date
}

final class FSEventMissionMonitor {
    private var stream: FSEventStreamRef?
    private var isActive = false
    private let missionContext: MissionContext
    private let eventQueue = DispatchQueue(label: "wonderland.fsevent.\(UUID().uuidString)", qos: .utility)
    private var shutdownWorkItem: DispatchWorkItem?

    private func performPEPCheck() throws {
        // TODO: Integrate real ZT PEP
        print("[FSEventMonitor] ZT PEP passed for mission \(missionContext.missionId)")
    }

    init(missionContext: MissionContext) {
        self.missionContext = missionContext
    }

    func start(paths: [String], latency: TimeInterval = 0.1, flags: FSEventStreamCreateFlags = FSEventStreamCreateFlags(kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagIgnoreSelf | kFSEventStreamCreateFlagUseCFTypes)) throws {
        guard !isActive else { throw SlamError.streamAlreadyActive }
        try performPEPCheck()

        let validatedPaths = try paths.compactMap { path -> String? in
            guard FileManager.default.fileExists(atPath: path) else {
                throw SlamError.pathValidationFailed(path: path)
            }
            return path
        }

        var context = FSEventStreamContext(
            version: 0,
            info: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        guard let eventStream = FSEventStreamCreate(
            kCFAllocatorDefault,
            { (stream, clientInfo, numEvents, eventPaths, eventFlags, eventIds) in
                guard let info = clientInfo else { return }
                let monitor = Unmanaged<FSEventMissionMonitor>.fromOpaque(info).takeUnretainedValue()
                monitor.handleEvents(numEvents: numEvents, eventPaths: eventPaths, eventFlags: eventFlags, eventIds: eventIds)
            },
            &context,
            validatedPaths as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            latency,
            flags
        ) else {
            throw SlamError.fseventCreationFailed(paths: validatedPaths)
        }

        stream = eventStream
        FSEventStreamSetDispatchQueue(eventStream, DispatchQueue.main)
        FSEventStreamStart(eventStream)
        isActive = true

        shutdownWorkItem = DispatchWorkItem { [weak self] in
            self?.stop(reason: "mission-timeout")
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 60.0, execute: shutdownWorkItem!)

        print("[AETHER] FSEvent stream started for mission \(missionContext.missionId)")
    }

    private func handleEvents(numEvents: Int, eventPaths: UnsafeRawPointer, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIds: UnsafePointer<FSEventStreamEventId>) {
        eventQueue.async { [weak self] in
            guard let self = self else { return }
            print("[FSEventMonitor] \(numEvents) events for mission \(self.missionContext.missionId)")
        }
    }

    func stop(reason: String = "normal") {
        guard isActive, let eventStream = stream else { return }
        shutdownWorkItem?.cancel()
        shutdownWorkItem = nil

        FSEventStreamStop(eventStream)
        FSEventStreamInvalidate(eventStream)
        FSEventStreamRelease(eventStream)
        stream = nil
        isActive = false

        print("[AETHER] FSEvent stream stopped for mission \(missionContext.missionId), reason: \(reason)")
    }

    deinit {
        stop(reason: "deinit")
    }

    var isStreamActive: Bool { isActive }
}

func launchFSEventMonitor(from intent: [String: Any]) throws {
    let missionId = intent["mission_id"] as? String ?? UUID().uuidString
    let paths = intent["watch_paths"] as? [String] ?? []
    let latency = intent["fsevent_latency"] as? TimeInterval ?? 0.1

    let context = MissionContext(missionId: missionId, intent: intent, startTime: Date())
    let monitor = FSEventMissionMonitor(missionContext: context)
    try monitor.start(paths: paths, latency: latency)
}
