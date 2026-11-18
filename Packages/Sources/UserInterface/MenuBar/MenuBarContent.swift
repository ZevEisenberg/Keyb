import AppKit
import ComposableArchitecture
import SwiftUI

/// The contents of the menu bar extra's menu.
public struct MenuBarContent: View {
  @Bindable
  var store: StoreOf<UserInterface>

  let mainWindowID: String
  let helpURL: URL

  @Environment(\.openWindow) private var openWindow
  @Environment(\.openURL) private var openURL

  public init(store: StoreOf<UserInterface>, mainWindowID: String, helpURL: URL) {
    self.store = store
    self.mainWindowID = mainWindowID
    self.helpURL = helpURL
  }

  public var body: some View {
    switch store.mode {
    case .unknown:
      // Replaced by the first permission check, right after launch.
      Toggle("Enable One-Handed Typing", isOn: .constant(false))
        .disabled(true)
    case .hasAccessibilityPermission:
      Toggle(
        "Enable One-Handed Typing",
        isOn: $store.mode.isRunning.sending(\.changeObservingState)
      )
    case .noAccessibilityPermission:
      Button("Set Up One-Handed Typing…", action: showMainWindow)
    }

    Divider()

    Button("Show Keyb Window", action: showMainWindow)
    Button("Keyb Help") { openURL(helpURL) }

    Divider()

    Button("Quit Keyb") { NSApplication.shared.terminate(nil) }
      .keyboardShortcut("q")
  }

  private func showMainWindow() {
    openWindow(id: mainWindowID)
    NSApplication.shared.activate()
  }
}
