import Dependencies
import DependenciesMacros
import XCTestDynamicOverlay

@DependencyClient
public struct AccessibilityClient {

    public var isCurrentlyTrusted: () -> Bool = { false }

}

public extension AccessibilityClient {

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

extension AccessibilityClient: TestDependencyKey {
    public static let testValue = AccessibilityClient()
}

public extension DependencyValues {
    var accessibilityClient: AccessibilityClient {
        get { self[AccessibilityClient.self] }
        set { self[AccessibilityClient.self] = newValue }
    }
}
