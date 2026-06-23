// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "WLClipboard",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "wl-clipboard", targets: ["WLClipboard"])
    ],
    targets: [
        .executableTarget(name: "WLClipboard")
    ]
)
