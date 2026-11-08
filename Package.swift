// swift-tools-version: 6.0

import PackageDescription

// The shell needs iOS 26. The package supports older systems so apps with a lower deployment target can link
// it; there, `SNNShell.isSupported()` is false and the app keeps its own root.
let package = Package(
    name: "SynapseNativeNav",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "SynapseNativeNav",
            targets: ["SynapseNativeNav"]
        ),
    ],
    targets: [
        .target(name: "SynapseNativeNav"),
        .testTarget(
            name: "SynapseNativeNavTests",
            dependencies: ["SynapseNativeNav"]
        ),
    ]
)
