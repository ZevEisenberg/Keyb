import AccessibilityClient
import AppKit
@preconcurrency import ApplicationServices.HIServices
import AsyncAlgorithms
import Dependencies
import Foundation
import os.log

private let permissionLog = Logger(subsystem: "accessibility", category: "permission")

extension AccessibilityClient: DependencyKey {
  public static var liveValue: Self {
    .init(
      isCurrentlyTrusted: {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let result = AXIsProcessTrustedWithOptions([promptFlag: false] as CFDictionary)
        return result
      },
      requestAccess: {
        let promptFlag = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        _ = AXIsProcessTrustedWithOptions([promptFlag: true] as CFDictionary)
      },
      permissionMayHaveChanged: {
        let trustListChanged = DistributedNotificationCenter.default()
          .signals(named: .accessibilityTrustListDidChange)
          // The new trust value can lag behind the notification, and Settings may post several
          // in a row, so wait for things to settle before re-checking.
          .debounce(for: .milliseconds(500))

        // Backstops in case the notification above is missed or stops being posted: re-check when
        // a menu opens (such as the menu bar extra) and when the app becomes active (such as when
        // the main window opens).
        let menuOpened = NotificationCenter.default.signals(named: NSMenu.didBeginTrackingNotification)
        let appBecameActive = NotificationCenter.default.signals(named: NSApplication.didBecomeActiveNotification)

        return merge(trustListChanged, menuOpened, appBecameActive).eraseToStream()
      }
    )
  }
}

private extension NotificationCenter {
  /// Emits each time `name` is posted. Unlike `notifications(named:)`, this works with
  /// AsyncAlgorithms, which needs `Sendable` elements, and `Notification` isn't `Sendable`.
  func signals(named name: Notification.Name) -> AsyncStream<Void> {
    AsyncStream { continuation in
      let observer = UncheckedSendable(
        addObserver(forName: name, object: nil, queue: nil) { _ in
          #if DEBUG
          // `.notice`, not `.debug`: debug messages stay in memory and get dropped, so they can't
          // be read back with `log show` during manual QA.
          permissionLog.notice("Received \(name.rawValue, privacy: .public)")
          #endif
          continuation.yield()
        }
      )
      continuation.onTermination = { [self] _ in
        removeObserver(observer.value)
      }
    }
  }
}

private extension Notification.Name {
  /// Posted to the distributed notification center when the list of apps allowed to use
  /// Accessibility changes: an app is added or removed, or its switch is turned on or off. In
  /// macOS 27.2.1 that list is under System Settings → Privacy & Security → Device Control and
  /// Data Access.
  ///
  /// **This is not public API.** Apple doesn't document this notification, and the SDK has no
  /// public way to learn that `AXIsProcessTrusted()` has changed. The only documented
  /// alternative is polling. As of the macOS 27.3 SDK, the closest public API,
  /// `AccessibilitySettings.applicationAccessibilityEnabledDidChangeNotification`, is unrelated:
  /// it reports assistive technologies such as VoiceOver reading this app, not this app's own
  /// permission.
  ///
  /// The notification carries no information about which app changed, so treat it only as a
  /// prompt to re-check. It isn't posted when an app is removed from the list (the − button),
  /// even though that revokes access. In that case, and if a future macOS stops posting it,
  /// `permissionMayHaveChanged`'s other triggers still catch the change, just later.
  ///
  /// Manual QA: in a Debug build, turn Keyb's switch off and on, then remove Keyb and add it back.
  /// Then run `/usr/bin/log show --last 10m --info --style compact --predicate 'subsystem ==
  /// "accessibility" AND category == "permission"'`. Expect `Received com.apple.accessibility.api`
  /// for each switch change and for the re-add, but not for the removal.
  static let accessibilityTrustListDidChange = Self("com.apple.accessibility.api")
}
