import AccessibilityClient
import ComposableArchitecture
import EventHandlerClient
import SwiftUI

@Reducer
public struct UserInterface {
  @ObservableState
  public struct State: Equatable {
    public enum Mode: Equatable {
      public enum NoAccessibilityPermissionReason: Equatable {
        case hasNotPromptedYet
        case permissionError
        case awaitingUser
      }

      /// Permission hasn't been checked yet, such as at launch before `task` runs.
      case unknown
      case hasAccessibilityPermission(isRunning: Bool)
      case noAccessibilityPermission(NoAccessibilityPermissionReason)

      var isRunning: Bool {
        switch self {
        case .hasAccessibilityPermission(isRunning: let isRunning):
          isRunning
        case .unknown,
             .noAccessibilityPermission:
          false
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

    /// Whether the user has ever been asked for, or has granted, Accessibility permission. Lets
    /// a missing permission be shown as denied or revoked rather than as first-time setup.
    @Shared(.hasPromptedForAccessibility)
    public var hasPromptedForAccessibility

    public var isRunning: Bool {
      get { mode.isRunning }
      set {
        if case .hasAccessibilityPermission = mode {
          mode = .hasAccessibilityPermission(isRunning: newValue)
        } else {
          // no-op, since if we have no permissions, we can't ever be running
        }
      }
    }

    public init(mode: Mode) {
      self.mode = mode
    }
  }

  public enum Action {
    case task
    case promptForPermission
    case promptedForPermission(isCurrentlyTrusted: Bool)
    case permissionChanged(hasAccessibilityPermission: Bool)
    case changeObservingState(observing: Bool)
    case startActiveCalled(startSuccess: Bool)
    case permissionsError
    case checkForPermissions
    case permissionErrorAppeared
  }

  @Dependency(\.accessibilityClient) var accessibilityClient
  @Dependency(\.eventHandlerClient) var eventHandlerClient
  @Dependency(\.mainQueue) var mainQueue

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      struct TimerID: Hashable {}

      switch action {
      case .task:
        return .merge(
          .send(.checkForPermissions),
          .run { [accessibilityClient] send in
            for await _ in accessibilityClient.permissionMayHaveChanged() {
              await send(.checkForPermissions)
            }
          }
        )

      case .checkForPermissions:
        // A quick, synchronous read, so the state is right as soon as this action is handled.
        return .send(.permissionChanged(hasAccessibilityPermission: accessibilityClient.isCurrentlyTrusted()))

      case .permissionErrorAppeared:
        // Settings only lists apps that have asked for access, and Keyb's entry may be gone, such as
        // after `tccutil reset` or the user removing it. Ask again so there's a switch to turn on.
        // If the user already denied access, this does nothing visible. A grant is picked up by
        // `permissionMayHaveChanged`.
        // TODO: #54. Asking again doesn't re-add Keyb after the user removes it from the list.
        return .run { [accessibilityClient] _ in
          accessibilityClient.requestAccess()
        }

      case .promptForPermission:
        state.$hasPromptedForAccessibility.withLock { $0 = true }
        return .run { [accessibilityClient] send in
          let isCurrentlyTrusted = accessibilityClient.isCurrentlyTrusted()
          await send(.promptedForPermission(isCurrentlyTrusted: isCurrentlyTrusted))
        }

      case .promptedForPermission(let isCurrentlyTrusted):
        guard !isCurrentlyTrusted else {
          state.mode = .hasAccessibilityPermission(isRunning: state.mode.isRunning)
          return .none
        }

        state.mode = .noAccessibilityPermission(.awaitingUser)
        return .run { [eventHandlerClient, mainQueue] send in
          let provisionalStartResult = await eventHandlerClient.startProvisional()
          await send(.permissionChanged(hasAccessibilityPermission: provisionalStartResult))

          for await _ in mainQueue.timer(interval: 0.5) {
            await send(.checkForPermissions)
          }
        }
        .cancellable(id: TimerID())

      case .permissionChanged(let hasAccessibilityPermission):
        if hasAccessibilityPermission {
          state.$hasPromptedForAccessibility.withLock { $0 = true }
          if !state.mode.hasPermission {
            state.mode = .hasAccessibilityPermission(isRunning: false)
          }
          return .cancel(id: TimerID())
        }

        switch state.mode {
        case .unknown:
          state.mode = .noAccessibilityPermission(
            state.hasPromptedForAccessibility ? .permissionError : .hasNotPromptedYet
          )
          return .none

        case .hasAccessibilityPermission(let isRunning):
          // Permission was revoked while the app was running.
          state.mode = .noAccessibilityPermission(.permissionError)
          guard isRunning else {
            return .none
          }
          return .run { @MainActor [eventHandlerClient] _ in
            eventHandlerClient.stop()
          }

        case .noAccessibilityPermission:
          return .none
        }

      case .changeObservingState(let observing):
        if observing {
          // Optimistically show as running so toggles respond immediately.
          // startActiveCalled corrects this if starting fails.
          state.isRunning = true
          return .run { @MainActor [eventHandlerClient] send in
            let startSuccess = eventHandlerClient.startActive()
            send(.startActiveCalled(startSuccess: startSuccess))
          }
        } else {
          state.mode = .hasAccessibilityPermission(isRunning: false)
          return .run { @MainActor [eventHandlerClient] _ in
            eventHandlerClient.stop()
          }
        }

      case .startActiveCalled(let startSuccess):
        state.mode = .hasAccessibilityPermission(isRunning: startSuccess)
        if startSuccess {
          return .none
        } else {
          return .send(.permissionsError)
        }

      case .permissionsError:
        state.mode = .noAccessibilityPermission(.permissionError)
        return .none
      }
    }
  }
}

public extension SharedKey where Self == AppStorageKey<Bool>.Default {
  static var hasPromptedForAccessibility: Self {
    Self[.appStorage("hasPromptedForAccessibility"), default: false]
  }
}

public struct UserInterfaceView: View {
  let store: StoreOf<UserInterface>

  public init(store: StoreOf<UserInterface>) {
    self.store = store
  }

  public var body: some View {
    Group {
      switch store.mode {
      case .unknown:
        // Replaced by the first permission check, right after launch.
        EmptyView()
      case .hasAccessibilityPermission:
        EnableDisableView(store: store)
      case .noAccessibilityPermission(let reason):
        switch reason {
        case .hasNotPromptedYet:
          OnboardingView(store: store)
        case .permissionError:
          PermissionErrorView(mode: .problem, store: store)
        case .awaitingUser:
          PermissionErrorView(mode: .awaiting, store: store)
        }
      }
    }
    .frame(width: 400)
    .padding()
  }
}

#Preview("Not Running") {
  UserInterfaceView(
    store: .init(
      initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient = .accessibilityIsEnabled
      $0.eventHandlerClient = .noop(enabled: false)
      $0.mainQueue = .immediate
    }
  )
}

#Preview("Running") {
  UserInterfaceView(
    store: .init(
      initialState: .init(mode: .hasAccessibilityPermission(isRunning: true)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient = .accessibilityIsEnabled
      $0.eventHandlerClient = .noop(enabled: true)
      $0.mainQueue = .immediate
    }
  )
}

#Preview("Not Prompted") {
  UserInterfaceView(
    store: .init(
      initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient = .accessibilityIsNotGranted
      $0.eventHandlerClient = .noop(enabled: true)
      $0.mainQueue = .immediate
    }
  )
}

#Preview("Permission Error") {
  UserInterfaceView(
    store: .init(
      initialState: .init(mode: .noAccessibilityPermission(.permissionError)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient = .accessibilityIsNotGranted
      $0.eventHandlerClient = .noop(enabled: true)
      $0.mainQueue = .immediate
    }
  )
}
