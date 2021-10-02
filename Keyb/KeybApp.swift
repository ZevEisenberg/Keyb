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

    var body: some Scene {
        WindowGroup("Keyb") {
            UserInterfaceView(store: appDelegate.store)
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button(action: {
                    openURL(URL(string: "https://zeveisenberg.com/keyb")!)
                }, label: {
                    Text("Keyb Help")
                })
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    let eventHandler = EventHandler()

    override init() {
        store = Store(
            initialState: UserInterfaceState(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
            reducer: appReducer,
            environment: .init(
                accessibilityClient: .live,
                eventHandlerClient: .live(with: eventHandler),
                mainQueue: .main
            )
        )
        super.init()
    }

    let store: Store<UserInterfaceState, UserInterfaceAction>

    lazy var viewStore = ViewStore(store.scope(state: \.appDelegate))

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard viewStore.hasPermission
        else { return nil }

        let isChecked = viewStore.isDockMenuItemChecked
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

    @objc func enable() {
        viewStore.send(.changeObservingState(observing: true))

    }

    @objc func disable() {
        viewStore.send(.changeObservingState(observing: false))
    }
}
