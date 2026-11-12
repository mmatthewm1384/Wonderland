// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Synapse",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Synapse",
            targets: ["Synapse"]
        ),
        .executable(
            name: "SynapseApp",
            targets: ["SynapseExecutable"]
        )
    ],
    targets: [
        .target(
            name: "Synapse",
            path: "Synapse",
            exclude: ["Tests", "App"]
        ),
        .executableTarget(
            name: "SynapseExecutable",
            dependencies: ["Synapse"],
            path: "Synapse/App"
        ),
        .testTarget(
            name: "SynapseTests",
            dependencies: ["Synapse"],
            path: "Synapse/Tests"
        )
    ]
)
