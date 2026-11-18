import Dependencies
import DependenciesMacros

@DependencyClient
public struct AccessibilityClient: Sendable {
  public var isCurrentlyTrusted: @Sendable () -> Bool = { false }

  /// Asks the system for Accessibility access. If the user hasn't answered yet, the system shows
  /// its alert. Once the user has denied access, the alert doesn't appear again, even after a
  /// relaunch, so this has no visible effect.
  ///
  /// TODO: #54. This was meant to add Keyb back to the list in System Settings after it's removed,
  /// but manual testing showed it doesn't. It may still help after `tccutil reset` (untested).
  public var requestAccess: @Sendable () -> Void

  /// Emits whenever Accessibility permission may have changed, or is worth re-checking, such as
  /// when the user changes the Accessibility list in System Settings or opens the menu bar menu.
  public var permissionMayHaveChanged: @Sendable () -> AsyncStream<Void> = { .finished }
}

public extension AccessibilityClient {
  static var accessibilityIsEnabled: Self {
    .init(
      isCurrentlyTrusted: {
        true
      },
      requestAccess: {},
      permissionMayHaveChanged: { .finished }
    )
  }

  static var accessibilityIsNotGranted: Self {
    .init(
      isCurrentlyTrusted: {
        false
      },
      requestAccess: {},
      permissionMayHaveChanged: { .finished }
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
