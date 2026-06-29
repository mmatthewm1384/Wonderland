// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WonderlandUI",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "WonderlandUI", targets: ["WonderlandUI"])
    ],
    targets: [
        .target(name: "WonderlandUI")
    ]
)
