// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BendProCore",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BendProCore",
            targets: ["BendProCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BendProCore",
            dependencies: []
        ),
        .testTarget(
            name: "BendProCoreTests",
            dependencies: ["BendProCore"]
        )
    ]
)
