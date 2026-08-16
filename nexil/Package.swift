// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Nexil",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "Nexil", targets: ["Nexil"])],
    targets: [
        .executableTarget(
            name: "Nexil",
            path: "Sources/Nexil",
            linkerSettings: [.linkedFramework("AppKit"), .linkedFramework("Carbon")]
        )
    ],
    swiftLanguageModes: [.v5]
)
