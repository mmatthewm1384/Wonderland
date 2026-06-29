import Foundation
import CoreServices

let defaultPath = FileManager.default.currentDirectoryPath
let watchPath = ProcessInfo.processInfo.environment["WL_MATRIX_SLAM_WATCH_PATH"] ?? defaultPath

var isDir: ObjCBool = false
guard FileManager.default.fileExists(atPath: watchPath, isDirectory: &isDir), isDir.boolValue else {
    fputs("FAIL watch path missing or not directory: \(watchPath)\n", stderr)
    exit(1)
}

let paths = [watchPath]

let callback: FSEventStreamCallback = { _, _, numEvents, eventPaths, eventFlags, eventIds in
    let pathArray = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] ?? []

    for i in 0..<Int(numEvents) {
        let path = i < pathArray.count ? pathArray[i] : "unknown"
        print("SLAM_TO_GROUND event_id=\(eventIds[i]) flags=\(eventFlags[i]) path=\(path)")
        fflush(stdout)
    }
}

guard let stream = FSEventStreamCreate(
    kCFAllocatorDefault,
    callback,
    nil,
    paths as CFArray,
    FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
    1.0,
    FSEventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes)
) else {
    fputs("FAIL create FSEventStream\n", stderr)
    exit(1)
}

let queue = DispatchQueue(label: "wl.matrix.slam-watch.events")
FSEventStreamSetDispatchQueue(stream, queue)

guard FSEventStreamStart(stream) else {
    fputs("FAIL start FSEventStream\n", stderr)
    FSEventStreamInvalidate(stream)
    FSEventStreamRelease(stream)
    exit(1)
}

print("PASS wl-matrix-slam-watch")
print("watching=\(watchPath)")
fflush(stdout)

dispatchMain()
