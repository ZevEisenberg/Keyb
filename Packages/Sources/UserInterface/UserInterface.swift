import AccessibilityClient
import EventHandlerClient
import ComposableArchitecture
import SwiftUI

public struct UserInterfaceState: Equatable {
    public enum Mode: Equatable {
        public enum NoAccessibilityPermissionReason: Equatable {
            case hasNotPromptedYet
            case permissionError
            case awaitingUser
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
    case checkForPermissions
}

public struct UserInterfaceEnvironment {
    public var accessibilityClient: AccessibilityClient
    public var eventHandlerClient: EventHandlerClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        accessibilityClient: AccessibilityClient,
        eventHandlerClient: EventHandlerClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.accessibilityClient = accessibilityClient
        self.eventHandlerClient = eventHandlerClient
        self.mainQueue = mainQueue
    }
}

public let userInterfaceReducer = Reducer<UserInterfaceState, UserInterfaceAction, UserInterfaceEnvironment> { state, action, environment in
    struct TimerID: Hashable {}

    switch action {
    case .checkForPermissions:
        let isCurrentlyTrusted = environment.accessibilityClient.isCurrentlyTrusted()
        return .init(value: .permissionChanged(hasAccessibilityPermission: isCurrentlyTrusted))

    case .promptForPermission:
        let isCurrentlyTrusted = environment.accessibilityClient.isCurrentlyTrusted()
        guard !isCurrentlyTrusted else {
            state.mode = .hasAccessibilityPermission(isRunning: state.mode.isRunning)
            return .none
        }

        state.mode = .noAccessibilityPermission(.awaitingUser)
        let provisionalStartResult = environment.eventHandlerClient.startProvisional()
        return .concatenate(
            .init(value: .permissionChanged(hasAccessibilityPermission: provisionalStartResult)),
            Effect.timer(id: TimerID(), every: 0.5, on: environment.mainQueue)
                .map { _ in .checkForPermissions }
        )

    case .permissionChanged(let hasAccessibilityPermission):
        var effects: [Effect<UserInterfaceAction, Never>] = [.none]
        if hasAccessibilityPermission {
            // cancel if permissions changed
            if case .noAccessibilityPermission = state.mode {
                effects.append(.cancel(id: TimerID()))
            }
            state.mode = .hasAccessibilityPermission(isRunning: state.mode.isRunning)
        }
        else {
            // cancel if permissions changed
            if case .hasAccessibilityPermission = state.mode {
                effects.append(.cancel(id: TimerID()))
            }
//            // TODO: can we learn more here?
//            state.mode = .noAccessibilityPermission(.hasNotPromptedYet)
        }
        return .concatenate(effects)

    case .startObservingEvents:
        let startSuccess = environment.eventHandlerClient.startActive()
        state.mode = .hasAccessibilityPermission(isRunning: startSuccess)
        if startSuccess {
            return .none
        } else {
            return .init(value: .permissionsError)
        }

    case .stopObservingEvents:
        state.mode = .hasAccessibilityPermission(isRunning: false)
        environment.eventHandlerClient.stop()
        return .none

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
            Group {
                switch viewStore.mode {
                case .hasAccessibilityPermission:
                    EnableDisableView(store: store)
                case .noAccessibilityPermission(let reason):
                    switch reason {
                    case .hasNotPromptedYet:
                        OnboardingView(store: store)
                    case .permissionError:
                        PermissionErrorView(mode: .problem)
                    case .awaitingUser:
                        PermissionErrorView(mode: .awaiting)
                    }
                }
            }
            .onAppear {
                viewStore.send(.checkForPermissions)
            }
        }
        .frame(width: 400)
        .padding()
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
                    eventHandlerClient: .noop(enabled: false),
                    mainQueue: .immediate
                )
            )
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .hasAccessibilityPermission(isRunning: true)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .accessibilityIsEnabled,
                    eventHandlerClient: .noop(enabled: true),
                    mainQueue: .immediate
                )
            )
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .accessibilityIsNotGranted,
                    eventHandlerClient: .noop(enabled: true),
                    mainQueue: .immediate
                )
            )
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.permissionError)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .accessibilityIsNotGranted,
                    eventHandlerClient: .noop(enabled: true),
                    mainQueue: .immediate
                )
            )
        )
    }
}
