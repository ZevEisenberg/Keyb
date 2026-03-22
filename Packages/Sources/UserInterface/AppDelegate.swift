import ComposableArchitecture

@Reducer
public struct AppDelegateFeature {
  @ObservableState
  public struct State: Equatable {
    public var isDockMenuItemChecked: Bool
    public var hasPermission: Bool
  }

  public typealias Action = UserInterface.Action

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .changeObservingState(observing: let observing):
        state.isDockMenuItemChecked = observing
        return .none
      default:
        return .none
      }
    }
  }
}

public extension UserInterface.State {
  var appDelegate: AppDelegateFeature.State {
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
