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
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "swift-adsb",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .target(
            name: "OpenSkyNetwork",
            dependencies: [ ]
        ),
        .testTarget(
            name: "swift-adsbTests",
            dependencies: ["swift-adsb"]
        ),
        .testTarget(
            name: "OpenSkyNetworkTests",
            dependencies: ["OpenSkyNetwork"]
        ),
    ]
)
