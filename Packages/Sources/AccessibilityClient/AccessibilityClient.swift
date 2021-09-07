public struct AccessibilityClient {

    public var isCurrentlyTrusted: () -> Bool

    public init(isCurrentlyTrusted: @escaping () -> Bool) {
        self.isCurrentlyTrusted = isCurrentlyTrusted
    }

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
