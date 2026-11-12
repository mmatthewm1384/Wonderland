// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AetherisHypervisor",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "hypervisor-runner",
            path: "Sources"
        )
    ]
)
