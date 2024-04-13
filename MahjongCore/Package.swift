// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MahjongCore",
    platforms: [
        .visionOS(.v1)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MahjongCore",
            targets: ["MahjongCore"]),
    ],
    dependencies: [
        .package(path: "../MahjongCommons"),
        .package(path: "../MahjongAnalyzer")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MahjongCore",
            dependencies: ["MahjongCommons", "MahjongAnalyzer"],
            resources: [
                .process("Model3D")
            ]),
        .testTarget(
            name: "MahjongCoreTests",
            dependencies: ["MahjongCore", "MahjongCommons"]),
    ]
)
