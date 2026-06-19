// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "wl-matrix-fluderation-pusher",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "wl-matrix-fluderation-pusher", targets: ["wl-matrix-fluderation-pusher"])
    ],
    targets: [
        .executableTarget(
            name: "wl-matrix-fluderation-pusher",
            path: "Sources/wl-matrix-fluderation-pusher"
        )
    ]
)
