// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClaudeCode",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v11),
        .tvOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(
            name: "ClaudeCode",
            targets: ["ClaudeCode"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.2.1")
    ],
    targets: [
        .target(
            name: "ClaudeCode",
            dependencies: [
                .product(name: "Subprocess", package: "swift-subprocess")
            ]
        ),
        .testTarget(
            name: "ClaudeCodeTests",
            dependencies: ["ClaudeCode"]
        ),
    ]
)
