// swift-tools-version: 6.4

import PackageDescription

// swiftformat:sort
let package = Package(
  name: "Packages",
  platforms: [
    .macOS(.v13),
  ],
  products: [
    .singleTargetLibrary("AccessibilityClient"),
    .singleTargetLibrary("AccessibilityClientLive"),
    .singleTargetLibrary("EventHandler"),
    .singleTargetLibrary("EventHandlerClient"),
    .singleTargetLibrary("EventHandlerClientLive"),
    .singleTargetLibrary("HumanReadable"),
    .singleTargetLibrary("KeyProcessor"),
    .singleTargetLibrary("UserInterface"),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      exact: "1.26.2",
      traits: ["ComposableArchitecture2Deprecations"]
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies",
      exact: "1.17.2"
    ),
  ],
  targets: [
    .target(
      name: "AccessibilityClient",
      dependencies: [
        .composableArchitecture,
        .dependenciesMacros,
      ]
    ),
    .target(
      name: "AccessibilityClientLive",
      dependencies: [
        .accessibilityClient,
      ]
    ),
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
        .composableArchitecture,
        .dependenciesMacros,
      ]
    ),
    .target(
      name: "EventHandlerClientLive",
      dependencies: [
        .eventHandler,
        .eventHandlerClient,
      ]
    ),
    .target(
      name: "HumanReadable"
    ),
    .target(
      name: "KeyProcessor",
      dependencies: [
        .humanReadable,
      ]
    ),
    .target(
      name: "UserInterface",
      dependencies: [
        .accessibilityClient,
        .composableArchitecture,
        .eventHandlerClient,
        .keyProcessor,
      ]
    ),
    .testTarget(
      name: "KeyProcessorTests",
      dependencies: [
        .humanReadable,
        .keyProcessor,
      ]
    ),
    .testTarget(
      name: "UserInterfaceTests",
      dependencies: [
        .userInterface,
      ]
    ),
  ]
)

extension Product {
  static func singleTargetLibrary(_ name: String) -> Product {
    .library(name: name, targets: [name])
  }
}

// Internal
// swiftformat:sort
extension Target.Dependency {
  static let accessibilityClient: Self = "AccessibilityClient"
  static let eventHandler: Self = "EventHandler"
  static let eventHandlerClient: Self = "EventHandlerClient"
  static let humanReadable: Self = "HumanReadable"
  static let keyProcessor: Self = "KeyProcessor"
  static let userInterface: Self = "UserInterface"
}

// External
// swiftformat:sort
extension Target.Dependency {
  static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let dependenciesMacros: Self = .product(name: "DependenciesMacros", package: "swift-dependencies")
}
