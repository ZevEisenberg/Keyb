import AccessibilityClientLive
import Combine
import ComposableArchitecture
import DockMenuClient
import EventHandler
import EventHandlerClientLive
import SwiftUI
import UserInterface

@main
struct KeybApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let eventHandler = EventHandler()

    var body: some Scene {
        WindowGroup {
            UserInterfaceView(store: Store(
                initialState: UserInterfaceState(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .live,
                    eventHandlerClient: .live(with: eventHandler),
                    dockMenuClient: .init(
                        isRunning: {
                            appDelegate.isDockMenuItemChecked.eraseToEffect()
                        },
                        updateIsRunning: { newValue in
                            Effect.fireAndForget {
                                appDelegate.isDockMenuItemChecked.value = newValue
                            }
                        }
                    ),
                    mainQueue: .main
                )
            ))
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var isDockMenuItemChecked: CurrentValueSubject<Bool, Never> = .init(false)

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        let item = NSMenuItem(
            title: "Enable One-Handed Typing",
            action: isDockMenuItemChecked.value ? #selector(disable) : #selector(enable),
            keyEquivalent: ""
        )
        // Checkmark if currently enabled
        item.state = isDockMenuItemChecked.value ? .on : .off
        menu.addItem(item)
        return menu
    }

    @objc func enable() {
        isDockMenuItemChecked.value = true
    }

    @objc func disable() {
        isDockMenuItemChecked.value = false
    }
}
