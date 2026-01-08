// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MagicPlayMan",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MagicPlayMan",
            targets: ["MagicPlayMan"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nookery/MagicKit.git", branch: "dev"),
    ],
    targets: [
        .target(
            name: "MagicPlayMan",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
            ]
        )
    ]
)
