import Dependencies
import XCTestDynamicOverlay

public struct AccessibilityClient {

    public var isCurrentlyTrusted: () -> Bool

    public init(isCurrentlyTrusted: @escaping () -> Bool) {
        self.isCurrentlyTrusted = isCurrentlyTrusted
    }

}

public extension AccessibilityClient {

    static let testValue: Self = .init(
        isCurrentlyTrusted: unimplemented("\(Self.self).isCurrentlyTrusted")
    )

    static var accessibilityIsEnabled: Self {
        .init(
            isCurrentlyTrusted: {
                true
            }
        )
    }

    static var accessibilityIsNotGranted: Self {
        .init(
            isCurrentlyTrusted: {
                false
            }
        )
    }
}

extension AccessibilityClient: TestDependencyKey {}

public extension DependencyValues {
    var accessibilityClient: AccessibilityClient {
        get { self[AccessibilityClient.self] }
        set { self[AccessibilityClient.self] = newValue }
    }
}
