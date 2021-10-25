// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SimpleButton",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "SimpleButton", targets: ["SimpleButton"])
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.9.0")),
    ],
    targets: [
        .target(name: "SimpleButton", dependencies: [], path: "SimpleButton/"),
        .testTarget(name: "SimpleButtonTests", dependencies: ["SimpleButton", "SnapshotTesting"], path: "SimpleButtonTests")
    ]
)
