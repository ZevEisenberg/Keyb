// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Packages",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "UserInterface",
            targets: ["UserInterface"]
        ),
        .library(
            name: "KeyProcessor",
            targets: ["KeyProcessor"]),
        .library(
            name: "AccessibilityClient",
            targets: ["AccessibilityClient"]),
        .library(
            name: "AccessibilityClientLive",
            targets: ["AccessibilityClientLive"]),
        .library(
            name: "EventHandler",
            targets: ["EventHandler"]),
        .library(
            name: "EventHandlerClient",
            targets: ["EventHandlerClient"]),
        .library(
            name: "EventHandlerClientLive",
            targets: ["EventHandlerClientLive"]),
        .library(
            name: "HumanReadable",
            targets: ["HumanReadable"])
    ],
    dependencies: [
        .package(name: "swift-composable-architecture", url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMinor(from: "0.26.0")),
    ],
    targets: [
        .target(
            name: "UserInterface",
            dependencies: [
                "AccessibilityClient",
                "EventHandlerClient",
                "KeyProcessor",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .testTarget(
            name: "UserInterfaceTests",
            dependencies: [
                "UserInterface",
            ]),
        .target(
            name: "KeyProcessor",
            dependencies: ["HumanReadable"]),
        .testTarget(
            name: "KeyProcessorTests",
            dependencies: [
                "HumanReadable",
                "KeyProcessor",
            ]),
        .target(
            name: "EventHandler",
            dependencies: [
                "HumanReadable",
                "KeyProcessor",
            ]
        ),
        .target(
            name: "EventHandlerClient",
            dependencies: [
            ]
        ),
        .target(
            name: "EventHandlerClientLive",
            dependencies: [
                "EventHandler",
                "EventHandlerClient",
            ]
        ),
        .target(
            name: "AccessibilityClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AccessibilityClientLive",
            dependencies: [
                "AccessibilityClient",
            ]
        ),
        .target(
            name: "HumanReadable")
    ]
)
