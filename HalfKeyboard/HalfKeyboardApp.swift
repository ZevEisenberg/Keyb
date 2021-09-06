import AccessibilityClientLive
import ComposableArchitecture
import EventHandler
import EventHandlerClientLive
import SwiftUI
import UserInterface

@main
struct HalfKeyboardApp: App {

    let eventHandler = EventHandler()

    var body: some Scene {
        WindowGroup {
            UserInterfaceView(store: Store(
                initialState: UserInterfaceState(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .live,
                    eventHandlerClient: .live(with: eventHandler)
                )
            ))
        }
    }
}
