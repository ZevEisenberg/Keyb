import AccessibilityClientLive
import Combine
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
      reducer: AppFeature.init
    )
    super.init()
  }

  let store: StoreOf<UserInterface>

  func applicationDockMenu(_: NSApplication) -> NSMenu? {
    guard store.appDelegate.hasPermission
    else { return nil }

    let isChecked = store.appDelegate.isDockMenuItemChecked
    let menu = NSMenu()
    let item = NSMenuItem(
      title: "Enable One-Handed Typing",
      action: isChecked ? #selector(disable) : #selector(enable),
      keyEquivalent: ""
    )
    // Checkmark if currently enabled
    item.state = isChecked ? .on : .off
    menu.addItem(item)
    return menu
  }

  @MainActor
  @objc func enable() {
    store.send(.changeObservingState(observing: true))
  }

  @MainActor
  @objc func disable() {
    store.send(.changeObservingState(observing: false))
  }
}
