import AccessibilityClient
import EventHandlerClient
import ComposableArchitecture
import SwiftUI

@Reducer
public struct UserInterface {
    public struct State: Equatable {
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

            public var hasPermission: Bool {
                if case .hasAccessibilityPermission = self {
                    return true
                }
                return false
            }
        }
        public var mode: Mode

        public var isRunning: Bool {
            get { mode.isRunning }
            set {
                if case .hasAccessibilityPermission = mode {
                    mode = .hasAccessibilityPermission(isRunning: newValue)
                }
                else {
                    // no-op, since if we have no permissions, we can't ever be running
                }
            }
        }

        public init(mode: Mode) {
            self.mode = mode
        }
    }

    public enum Action: Equatable {
        case didAppear
        case promptForPermission
        case permissionChanged(hasAccessibilityPermission: Bool)
        case changeObservingState(observing: Bool)
        case permissionsError
        case checkForPermissions
    }

    @Dependency(\.accessibilityClient) var accessibilityClient
    @Dependency(\.eventHandlerClient) var eventHandlerClient
    @Dependency(\.mainQueue) var mainQueue

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        struct TimerID: Hashable {}

        switch action {
        case .didAppear:
            return .send(.checkForPermissions)

        case .checkForPermissions:
            let isCurrentlyTrusted = accessibilityClient.isCurrentlyTrusted()
            return .send(.permissionChanged(hasAccessibilityPermission: isCurrentlyTrusted))

        case .promptForPermission:
            let isCurrentlyTrusted = accessibilityClient.isCurrentlyTrusted()
            guard !isCurrentlyTrusted else {
                state.mode = .hasAccessibilityPermission(isRunning: state.mode.isRunning)
                return .none
            }

            state.mode = .noAccessibilityPermission(.awaitingUser)
            let provisionalStartResult = eventHandlerClient.startProvisional()
            return .run { send in
                await send(.permissionChanged(hasAccessibilityPermission: provisionalStartResult))

                for await _ in mainQueue.timer(interval: 0.5) {
                    await send(.checkForPermissions)
                }
            }
            .cancellable(id: TimerID())

        case .permissionChanged(let hasAccessibilityPermission):
            var effects: [Effect<UserInterface.Action>] = [.none]
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

        case .changeObservingState(observing: true):
            let startSuccess = eventHandlerClient.startActive()
            state.mode = .hasAccessibilityPermission(isRunning: startSuccess)
            if startSuccess {
                return .none
            } else {
                return .send(.permissionsError)
            }

        case .changeObservingState(observing: false):
            state.mode = .hasAccessibilityPermission(isRunning: false)
            eventHandlerClient.stop()
            return .none

        case .permissionsError:
            state.mode = .noAccessibilityPermission(.permissionError)
            return .none
        }

    }
}

@Reducer
public struct AppFeature {
    public typealias State = UserInterface.State
    public typealias Action = UserInterface.Action

    public init() {}

    public var body: some Reducer<UserInterface.State, UserInterface.Action> {
        UserInterface()
        Scope(state: \.appDelegate, action: \.self) {
            AppDelegateFeature()
        }
        Scope(state: \UserInterface.State.appDelegate, action: \.self) {
            AppDelegateFeature()
        }
    }
}

public struct UserInterfaceView: View {

    let store: StoreOf<UserInterface>

    public init(store: StoreOf<UserInterface>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: \.mode) { viewStore in
            Group {
                switch viewStore.state {
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
                viewStore.send(.didAppear)
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
                reducer: AppFeature.init
            ) {
                $0.accessibilityClient = .accessibilityIsEnabled
                $0.eventHandlerClient = .noop(enabled: false)
                $0.mainQueue = .immediate
            }
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .hasAccessibilityPermission(isRunning: true)),
                reducer: AppFeature.init
            ) {
                $0.accessibilityClient = .accessibilityIsEnabled
                $0.eventHandlerClient = .noop(enabled: true)
                $0.mainQueue = .immediate
            }
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
                reducer: AppFeature.init
            ) {
                $0.accessibilityClient = .accessibilityIsNotGranted
                $0.eventHandlerClient = .noop(enabled: true)
                $0.mainQueue = .immediate
            }
        )

        UserInterfaceView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.permissionError)),
                reducer: AppFeature.init
            ) {
                $0.accessibilityClient = .accessibilityIsNotGranted
                $0.eventHandlerClient = .noop(enabled: true)
                $0.mainQueue = .immediate
            }
        )
    }
}
