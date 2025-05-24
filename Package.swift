// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "LlamaCLI",
    platforms: [
        .macOS(.v10_15) // Or a newer version like .v12 or .v13
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"), // Use the latest appropriate version
    ],
    targets: [
        .executableTarget(
            name: "LlamaCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)