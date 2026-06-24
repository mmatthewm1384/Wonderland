// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WonderlandTimeTravel",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "WonderlandTimeTravel",
            targets: ["WonderlandTimeTravel"]
        )
    ],
    targets: [
        .executableTarget(
            name: "WonderlandTimeTravel"
        )
    ]
)
