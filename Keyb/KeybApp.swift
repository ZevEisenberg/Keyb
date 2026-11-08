import AccessibilityClient
import AccessibilityClientLive
import ComposableArchitecture
import EventHandler
import EventHandlerClientLive
import SwiftUI
import UserInterface

@main
struct KeybApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @Environment(\.openURL) var openURL

  private static let mainWindowID = "main"
  private static let helpURL = URL(string: "https://zeveisenberg.com/keyb")!

  var body: some Scene {
    Window("Keyb", id: Self.mainWindowID) {
      UserInterfaceView(store: appDelegate.store)
    }
    .commands {
      CommandGroup(replacing: .help) {
        Button(action: {
          openURL(Self.helpURL)
        }, label: {
          Text("Keyb Help")
        })
      }
    }

    MenuBarExtra {
      MenuBarContent(
        store: appDelegate.store,
        mainWindowID: Self.mainWindowID,
        helpURL: Self.helpURL
      )
    } label: {
      MenuBarLabel(store: appDelegate.store)
    }
  }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
  @MainActor
  override init() {
    self.store = Store(
      initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
      reducer: UserInterface.init
    )
    super.init()
  }

  let store: StoreOf<UserInterface>

  @Dependency(\.accessibilityClient) private var accessibilityClient

  @MainActor
  func applicationDidFinishLaunching(_: Notification) {
    // Keyb lives in the menu bar (LSUIElement). Only show the main window at
    // launch when the user still needs to grant Accessibility permission.
    store.send(.checkForPermissions)
    if accessibilityClient.isCurrentlyTrusted() {
      for window in NSApp.windows where window.canBecomeMain {
        window.close()
      }
    } else {
      NSApp.activate(ignoringOtherApps: true)
    }
  }
}
