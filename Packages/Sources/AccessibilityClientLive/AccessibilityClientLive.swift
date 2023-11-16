import ApplicationServices.HIServices
import AccessibilityClient
import Dependencies
import Foundation

extension AccessibilityClient: DependencyKey {
    public static let liveValue = Self(
        isCurrentlyTrusted: {
            let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
            let result = AXIsProcessTrustedWithOptions([promptFlag: false] as CFDictionary)
            return result
        }
    )
}

