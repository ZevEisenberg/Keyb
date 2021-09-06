import AccessibilityClient
import EventHandlerClient
import ComposableArchitecture
import SwiftUI

public struct UserInterfaceState: Equatable {
    public enum Mode: Equatable {
        public enum NoAccessibilityPermissionReason: Equatable {
            case hasNotPromptedYet
            case permissionError
        }

        case hasAccessibilityPermission(isRunning: Bool)
        case noAccessibilityPermission(NoAccessibilityPermissionReason)

        var isRunning: Bool {
            switch self {
            case .hasAccessibilityPermission(isRunning: let isRunning):
                return isRunning
            case .noAccessibilityPermission:
                return false
            }
        }
    }
    public var mode: Mode

    public init(mode: Mode) {
        self.mode = mode
    }
}

public enum UserInterfaceAction: Equatable {
    case promptForPermission
    case permissionChanged(hasAccessibilityPermission: Bool)
    case startObservingEvents
    case stopObservingEvents
    case permissionsError
}

public struct UserInterfaceEnvironment {
    public var accessibilityClient: AccessibilityClient
    public var eventHandlerClient: EventHandlerClient

    public init(
        accessibilityClient: AccessibilityClient,
        eventHandlerClient: EventHandlerClient
    ) {
        self.accessibilityClient = accessibilityClient
        self.eventHandlerClient = eventHandlerClient
    }
}

public let userInterfaceReducer = Reducer<UserInterfaceState, UserInterfaceAction, UserInterfaceEnvironment> { state, action, environment in
    switch action {
    case .promptForPermission:
        let newValue = environment.accessibilityClient.promptForTrust()
        return .init(value: .permissionChanged(hasAccessibilityPermission: newValue))

    case .permissionChanged(let hasAccessibilityPermission):
        if hasAccessibilityPermission {
            state.mode = .hasAccessibilityPermission(isRunning: state.mode.isRunning)
        }
        else {
            // TODO: can we learn more here?
            state.mode = .noAccessibilityPermission(.hasNotPromptedYet)
        }
        return .none

    case .startObservingEvents:
        let startSuccess = environment.eventHandlerClient.start()
        if startSuccess {
            return .none
        } else {
            return .init(value: .permissionsError)
        }

    case .stopObservingEvents:
        return .fireAndForget {
            environment.eventHandlerClient.stop()
        }
    case .permissionsError:
        state.mode = .noAccessibilityPermission(.permissionError)
        return .none
    }
}

public struct UserInterfaceView: View {

    let store: Store<UserInterfaceState, UserInterfaceAction>

    public init(store: Store<UserInterfaceState, UserInterfaceAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.mode {
            case .hasAccessibilityPermission:
                EnableDisableView(store: store)
            case .noAccessibilityPermission(let reason):
                switch reason {
                case .hasNotPromptedYet:
                    OnboardingView(store: store)
                case .permissionError:
                    PermissionErrorView()
                }
            }
        }
    }
}

struct UserInterfaceView_Previews: PreviewProvider {
    static var previews: some View {
        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .accessibilityIsEnabled,
                    eventHandlerClient: .noop(enabled: false)
                )
            )
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .hasAccessibilityPermission(isRunning: true)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .accessibilityIsEnabled,
                    eventHandlerClient: .noop(enabled: true)
                )
            )
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .noop,
                    eventHandlerClient: .noop(enabled: true)
                )
            )
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.permissionError)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .noop,
                    eventHandlerClient: .noop(enabled: true)
                )
            )
        )

    }
}
