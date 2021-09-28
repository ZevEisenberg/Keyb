// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension Target.Dependency {
    static let accessibilityClient: Self = "AccessibilityClient"
    static let dockMenuClient: Self = "DockMenuClient"
    static let eventHandlerClient: Self = "EventHandlerClient"
    static let humanReadable: Self = "HumanReadable"
    static let keyProcessor: Self = "KeyProcessor"
    static let userInterface: Self = "UserInterface"

    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
}

let package = Package(
    name: "Packages",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .singleTargetLibrary("UserInterface"),
        .singleTargetLibrary("KeyProcessor"),
        .singleTargetLibrary("AccessibilityClient"),
        .singleTargetLibrary("AccessibilityClientLive"),
        .singleTargetLibrary("EventHandler"),
        .singleTargetLibrary("EventHandlerClient"),
        .singleTargetLibrary("EventHandlerClientLive"),
        .singleTargetLibrary("HumanReadable"),
        .singleTargetLibrary("DockMenuClient"),
    ],
    dependencies: [
        .package(name: "swift-composable-architecture", url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMinor(from: "0.27.0")),
    ],
    targets: [
        .target(
            name: "UserInterface",
            dependencies: [
                .accessibilityClient,
                .eventHandlerClient,
                .keyProcessor,
                .dockMenuClient,
                .composableArchitecture,
            ]),
        .testTarget(
            name: "UserInterfaceTests",
            dependencies: [
                .userInterface,
            ]),
        .target(
            name: "KeyProcessor",
            dependencies: [
                .humanReadable,
            ]),
        .testTarget(
            name: "KeyProcessorTests",
            dependencies: [
                .humanReadable,
                .keyProcessor,
            ]),
        .target(
            name: "EventHandler",
            dependencies: [
                .humanReadable,
                .keyProcessor,
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
                .eventHandlerClient,
            ]
        ),
        .target(
            name: "AccessibilityClient",
            dependencies: [
                .composableArchitecture,
            ]
        ),
        .target(
            name: "AccessibilityClientLive",
            dependencies: [
                .accessibilityClient,
            ]
        ),
        .target(
            name: "HumanReadable"),
        .target(
            name: "DockMenuClient",
            dependencies: [
                .composableArchitecture,
            ]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
