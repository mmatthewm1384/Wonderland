import Foundation
// Paste the FSEventMissionMonitor content or include it
let intent: [String: Any] = [
    "mission_id": "sample-fsevent-001",
    "watch_paths": ["/tmp/wonderland-test"],
    "fsevent_latency": 0.1
]

do {
    try launchFSEventMonitor(from: intent)
    print("Monitor started.")
    RunLoop.current.run(until: Date(timeIntervalSinceNow: 30))
} catch {
    print("Error: \(error)")
}
