import ApplicationServices.HIServices
import AccessibilityClient
import Foundation

public extension AccessibilityClient {
    static var live: Self {
        .init(
            isCurrentlyTrusted: {
                let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
                let result = AXIsProcessTrustedWithOptions([promptFlag: false] as CFDictionary)
                return result
            },
            promptForTrust: {
                let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
                let result = AXIsProcessTrustedWithOptions([promptFlag: true] as CFDictionary)
                return result
            }
        )
    }
}
