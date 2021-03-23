// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-adsb",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "swift-adsb",
            targets: ["swift-adsb", "OpenSkyNetwork"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:apple/swift-log.git", .upToNextMajor(from: "1.4.2"))
    ],
    targets: [
        .target(
            name: "swift-adsb",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
            name: "OpenSkyNetwork",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "OpenSkyNetworkTests",
            dependencies: ["OpenSkyNetwork"]
        ),
    ]
)
