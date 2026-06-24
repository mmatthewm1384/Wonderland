// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "FSEventMissionMonitor",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "FSEventMissionMonitor", targets: ["FSEventMissionMonitor"])
    ],
    targets: [
        .target(
            name: "FSEventMissionMonitor",
            path: "Sources"
        ),
        .testTarget(
            name: "FSEventMissionMonitorTests",
            dependencies: ["FSEventMissionMonitor"],
            path: "Tests/FSEventMissionMonitorTests"
        )
    ]
)
