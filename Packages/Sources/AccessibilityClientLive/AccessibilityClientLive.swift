import ApplicationServices.HIServices
import AccessibilityClient
import Foundation

public extension AccessibilityClient {
    static var live: Self {
        .init(
            isCurrentlyTrusted: {
                let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
                return AXIsProcessTrustedWithOptions([promptFlag: false] as CFDictionary)
            },
            promptForTrust: {
                let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
                return AXIsProcessTrustedWithOptions([promptFlag: true] as CFDictionary)
            }
        )
    }
}
