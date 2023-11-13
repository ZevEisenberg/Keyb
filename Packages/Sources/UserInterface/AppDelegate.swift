import ComposableArchitecture

@Reducer
public struct AppDelegateFeature {

    public struct State: Equatable {
        public var isDockMenuItemChecked: Bool
        public var hasPermission: Bool
    }

    public func reduce(into state: inout State, action: UserInterface.Action) -> Effect<UserInterface.Action> {
        switch action {
        case .changeObservingState(observing: let observing):
            state.isDockMenuItemChecked = observing
            return .none
        default:
            return .none
        }
    }
}

extension UserInterface.State {
    public var appDelegate: AppDelegateFeature.State {
        get {
            .init(
                isDockMenuItemChecked: isRunning,
                hasPermission: mode.hasPermission
            )
        }
        set {
            isRunning = newValue.isDockMenuItemChecked
            // We don't update permission here because checking or unchecking the menu item doesn't change whether we have permission.
        }
    }
}
