// swift-tools-version: 5.9
import Foundation
import PackageDescription

let aetherisRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path

let package = Package(
    name: "WonderlandApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "WonderlandCoreLib", targets: ["WonderlandApp"]),
        .executable(name: "WonderlandApp", targets: ["WonderlandAppExec"])
    ],
    targets: [
        .target(
            name: "WonderlandApp",
            dependencies: [],
            path: "ui",
            exclude: [
                "Libs"
            ],
            linkerSettings: [
                .linkedFramework("Virtualization"),
                .linkedLibrary("wonderland_core"),
                .unsafeFlags([
                    "-L\(aetherisRoot)/target/release"
                ])
            ]
        ),
        .executableTarget(
            name: "WonderlandAppExec",
            dependencies: ["WonderlandApp"],
            path: "Sources/Exec"
        ),
        .testTarget(
            name: "WonderlandTests",
            dependencies: ["WonderlandApp"],
            path: "Tests/WonderlandTests"
        )
    ]
)
