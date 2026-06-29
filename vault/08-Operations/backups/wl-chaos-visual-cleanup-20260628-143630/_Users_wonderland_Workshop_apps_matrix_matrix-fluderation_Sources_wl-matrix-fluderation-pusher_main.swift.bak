import Foundation
import CoreServices

let args = CommandLine.arguments
let watchPath = ProcessInfo.processInfo.environment["WL_MATRIX_FLUDERATION_PATH"]
    ?? FileManager.default.currentDirectoryPath

if args.contains("--help") {
    print("""
    wl-matrix-fluderation-pusher

    Environment:
      WL_MATRIX_FLUDERATION_PATH=/path/to/watch

    Output:
      MATRIX_FLUDERATION_PUSH event_id=<id> flags=<flags> path=<path>
    """)
    exit(0)
}

var isDir: ObjCBool = false
guard FileManager.default.fileExists(atPath: watchPath, isDirectory: &isDir), isDir.boolValue else {
    fputs("FAIL watch path missing or not directory: \(watchPath)\n", stderr)
    exit(1)
}

let callback: FSEventStreamCallback = { _, _, numEvents, eventPaths, eventFlags, eventIds in
    let pathArray = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] ?? []

    for i in 0..<Int(numEvents) {
        let path = i < pathArray.count ? pathArray[i] : "unknown"
        print("MATRIX_FLUDERATION_PUSH event_id=\(eventIds[i]) flags=\(eventFlags[i]) path=\(path)")
        fflush(stdout)
    }
}

guard let stream = FSEventStreamCreate(
    kCFAllocatorDefault,
    callback,
    nil,
    [watchPath] as CFArray,
    FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
    0.25,
    FSEventStreamCreateFlags(
        kFSEventStreamCreateFlagFileEvents |
        kFSEventStreamCreateFlagUseCFTypes
    )
) else {
    fputs("FAIL create FSEventStream\n", stderr)
    exit(1)
}

let queue = DispatchQueue(label: "wl.matrix.fluderation.events")
FSEventStreamSetDispatchQueue(stream, queue)

guard FSEventStreamStart(stream) else {
    fputs("FAIL start FSEventStream\n", stderr)
    FSEventStreamInvalidate(stream)
    FSEventStreamRelease(stream)
    exit(1)
}

print("PASS wl-matrix-fluderation-pusher")
print("profile=matrix")
print("watching=\(watchPath)")
fflush(stdout)

dispatchMain()
