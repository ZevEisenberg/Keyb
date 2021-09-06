public struct AccessibilityClient {

    public var isCurrentlyTrusted: () -> Bool
    public var promptForTrust: () -> Bool

    public init(isCurrentlyTrusted: @escaping () -> Bool, promptForTrust: @escaping () -> Bool) {
        self.isCurrentlyTrusted = isCurrentlyTrusted
        self.promptForTrust = promptForTrust
    }

}

public extension AccessibilityClient {

    static var accessibilityIsEnabled: Self {
        .init(
            isCurrentlyTrusted: {
                true
            },
            promptForTrust: {
                fatalError("Should never need to prompt if accessibility is already granted")
            })
    }

    static var noop: Self {
        .init(
            isCurrentlyTrusted: {
                false
            },
            promptForTrust: {
                false
            }
        )
    }

    static var grantsWhenPrompted: Self {
        var isCurrentlyAllowed = false
        return .init(
            isCurrentlyTrusted: {
                isCurrentlyAllowed
            },
            promptForTrust: {
                isCurrentlyAllowed = true
                return true
            }
        )
    }
}
