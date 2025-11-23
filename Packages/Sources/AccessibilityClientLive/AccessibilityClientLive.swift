import AccessibilityClient
@preconcurrency import ApplicationServices.HIServices
import Dependencies
import Foundation

extension AccessibilityClient: DependencyKey {
  public static var liveValue: Self {
    .init(
      isCurrentlyTrusted: {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let result = AXIsProcessTrustedWithOptions([promptFlag: false] as CFDictionary)
        return result
      }
    )
  }
}
