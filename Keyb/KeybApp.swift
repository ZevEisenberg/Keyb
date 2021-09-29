import AccessibilityClientLive
import Combine
import ComposableArchitecture
import EventHandler
import EventHandlerClientLive
import SwiftUI
import UserInterface

let eventHandler = EventHandler()

@main
struct KeybApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let store = Store(
        initialState: UserInterfaceState(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
        reducer: userInterfaceReducer
            .combined(with: appDelegateReducer.pullback(state: \.appDelegate, action: /.self, environment: { _ in })),
        environment: .init(
            accessibilityClient: .live,
            eventHandlerClient: .live(with: eventHandler),
            mainQueue: .main
        )
    )

    init() {
        appDelegate.store = store.scope(state: \.appDelegate)
    }

    var body: some Scene {
        WindowGroup {
            UserInterfaceView(store: store)
        }
    }
}

extension UserInterfaceState {
    var appDelegate: AppDelegate.State {
        get {
            .init(
                isDockMenuItemChecked: isRunning,
                hasPermission: mode.hasPermission
            )
        }
        set {
            isRunning = newValue.isDockMenuItemChecked
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {

    struct State: Equatable {
        var isDockMenuItemChecked: Bool
        var hasPermission: Bool
    }

    var store: Store<State, UserInterfaceAction>?

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard
            let store = store,
            case let viewStore = ViewStore(store),
            viewStore.hasPermission
        else { return nil }

        let isChecked = viewStore.isDockMenuItemChecked
        print("checked:", isChecked)
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
        store.map(ViewStore.init)?.send(.changeObservingState(observing: true))

    }

    @objc func disable() {
        store.map(ViewStore.init)?.send(.changeObservingState(observing: false))
    }
}

let appDelegateReducer = Reducer<AppDelegate.State, UserInterfaceAction, Void> { state, action, _ in
    switch action {
    case .changeObservingState(observing: let observing):
        state.isDockMenuItemChecked = observing
        return .none
    default:
        return .none
    }
}
