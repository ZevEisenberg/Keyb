import ComposableArchitecture

public struct AppDelegateState: Equatable {
    public var isDockMenuItemChecked: Bool
    public var hasPermission: Bool
}

let appDelegateReducer = Reducer<AppDelegateState, UserInterfaceAction, Void> { state, action, _ in
    switch action {
    case .changeObservingState(observing: let observing):
        state.isDockMenuItemChecked = observing
        return .none
    default:
        return .none
    }
}

extension UserInterfaceState {
    public var appDelegate: AppDelegateState {
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
