import ApplicationServices.HIServices
import AccessibilityClient
import Dependencies
import Foundation

public extension AccessibilityClient {
    static var live: Self {
        .init(
            isCurrentlyTrusted: {
                let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
                let result = AXIsProcessTrustedWithOptions([promptFlag: false] as CFDictionary)
                return result
            }
        )
    }
}

extension AccessibilityClient: DependencyKey {
    public static let liveValue = AccessibilityClient.live
}
