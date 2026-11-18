import AccessibilityClient
import Combine
import ComposableArchitecture
import DependenciesTestSupport
import Dispatch
import EventHandlerClient
import Foundation
import Testing
import UserInterface

/// `.dependencies` gives each test, and each repetition of it, fresh dependencies such as app storage.
@MainActor
@Suite(.dependencies)
struct UserInterfaceTests {
  /// App storage for a user who granted permission in an earlier session.
  static var previouslyGrantedStorage: UserDefaults {
    let defaults = UserDefaults.inMemory
    defaults.set(true, forKey: "hasPromptedForAccessibility")
    return defaults
  }

  @Test
  func happyPath() async {
    let mainQueue = DispatchQueue.test

    let currentlyTrusted = LockIsolated(false)
    let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

    let store = TestStore(
      initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient.isCurrentlyTrusted = { currentlyTrusted.value }
      $0.eventHandlerClient = .init(
        isEnabled: { eventHandlerIsRunning },
        startProvisional: {
          currentlyTrusted.setValue(true)
          return true
        },
        startActive: {
          eventHandlerIsRunning.value = true
          return true
        },
        stop: {
          eventHandlerIsRunning.value = false
        }
      )
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    }

    await store.send(\.checkForPermissions)
    await store.receive(\.permissionChanged, false)

    await mainQueue.advance(by: 5)

    #expect(!currentlyTrusted.value)

    // User grants permission. Doesn't really affect the test. Mostly here as documentation.
    currentlyTrusted.setValue(true)

    await store.send(\.permissionChanged, true) {
      $0.mode = .hasAccessibilityPermission(isRunning: false)
      $0.$hasPromptedForAccessibility.withLock { $0 = true }
    }

    await store.send(\.changeObservingState, true) {
      $0.mode = .hasAccessibilityPermission(isRunning: true)
    }

    await store.receive(\.startActiveCalled, true)

    #expect(eventHandlerIsRunning.value)

    await store.send(\.changeObservingState, false) {
      $0.mode = .hasAccessibilityPermission(isRunning: false)
    }

    #expect(!eventHandlerIsRunning.value)
  }

  @Test
  func alreadyHasPermission() async {
    let mainQueue = DispatchQueue.test

    let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

    let store = TestStore(
      initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
      reducer: UserInterface.init
    ) {
      $0.defaultAppStorage = Self.previouslyGrantedStorage
      $0.accessibilityClient = .accessibilityIsEnabled
      $0.eventHandlerClient = .init(
        isEnabled: { eventHandlerIsRunning },
        startProvisional: { true },
        startActive: {
          eventHandlerIsRunning.value = true
          return true
        },
        stop: {
          eventHandlerIsRunning.value = false
        }
      )
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    }

    await store.send(\.checkForPermissions)
    await store.receive(\.permissionChanged, true)

    await mainQueue.advance(by: 5)

    await store.send(\.changeObservingState, true) {
      $0.mode = .hasAccessibilityPermission(isRunning: true)
    }

    await store.receive(\.startActiveCalled, true)

    #expect(eventHandlerIsRunning.value)

    await store.send(\.changeObservingState, false) {
      $0.mode = .hasAccessibilityPermission(isRunning: false)
    }

    #expect(!eventHandlerIsRunning.value)
  }

  @Test
  func launchWithPermission() async {
    let store = TestStore(initialState: .init(mode: .unknown), reducer: UserInterface.init) {
      $0.accessibilityClient = .accessibilityIsEnabled
    }

    // The first check runs synchronously, and `@Shared` is a reference, so the flag it sets is
    // already visible at this step.
    await store.send(.task) {
      $0.$hasPromptedForAccessibility.withLock { $0 = true }
    }
    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, true) {
      $0.mode = .hasAccessibilityPermission(isRunning: false)
    }
  }

  @Test
  func firstLaunch() async {
    let store = TestStore(initialState: .init(mode: .unknown), reducer: UserInterface.init) {
      $0.accessibilityClient = .accessibilityIsNotGranted
    }

    await store.send(.task)
    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, false) {
      $0.mode = .noAccessibilityPermission(.hasNotPromptedYet)
    }
  }

  @Test
  func launchAfterPermissionWasDeniedOrRevoked() async {
    let store = TestStore(initialState: .init(mode: .unknown), reducer: UserInterface.init) {
      $0.defaultAppStorage = Self.previouslyGrantedStorage
      $0.accessibilityClient = .accessibilityIsNotGranted
    }

    await store.send(.task)
    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, false) {
      $0.mode = .noAccessibilityPermission(.permissionError)
    }
  }

  @Test
  func revokedWhileRunning() async {
    let currentlyTrusted = LockIsolated(true)
    let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(true)
    let (changes, changesContinuation) = AsyncStream<Void>.makeStream()

    let store = TestStore(
      initialState: .init(mode: .hasAccessibilityPermission(isRunning: true)),
      reducer: UserInterface.init
    ) {
      $0.defaultAppStorage = Self.previouslyGrantedStorage
      $0.accessibilityClient = .init(
        isCurrentlyTrusted: { currentlyTrusted.value },
        requestAccess: {},
        permissionMayHaveChanged: { changes }
      )
      $0.eventHandlerClient.stop = { eventHandlerIsRunning.value = false }
    }

    let task = await store.send(.task)
    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, true)

    // The user turns off Keyb in System Settings.
    currentlyTrusted.setValue(false)
    changesContinuation.yield()

    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, false) {
      $0.mode = .noAccessibilityPermission(.permissionError)
    }

    // The user turns it back on.
    currentlyTrusted.setValue(true)
    changesContinuation.yield()

    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, true) {
      $0.mode = .hasAccessibilityPermission(isRunning: false)
    }

    await task.cancel()
    await store.finish()
    #expect(!eventHandlerIsRunning.value)
  }

  @Test
  func grantingPermissionStopsPolling() async {
    let mainQueue = DispatchQueue.test
    let currentlyTrusted = LockIsolated(false)

    let store = TestStore(
      initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient.isCurrentlyTrusted = { currentlyTrusted.value }
      $0.eventHandlerClient.startProvisional = { false }
      $0.mainQueue = mainQueue.eraseToAnyScheduler()
    }

    await store.send(.promptForPermission) {
      $0.$hasPromptedForAccessibility.withLock { $0 = true }
    }
    await store.receive(\.promptedForPermission, false) {
      $0.mode = .noAccessibilityPermission(.awaitingUser)
    }
    await store.receive(\.permissionChanged, false)

    await mainQueue.advance(by: 0.5)
    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, false)

    currentlyTrusted.setValue(true)
    await mainQueue.advance(by: 0.5)
    await store.receive(\.checkForPermissions)
    await store.receive(\.permissionChanged, true) {
      $0.mode = .hasAccessibilityPermission(isRunning: false)
    }

    // No more polling: the TestStore would fail on unreceived actions.
    await mainQueue.advance(by: 5)
  }

  /// After `tccutil reset`, or after the user removes Keyb from the list, Keyb isn't listed in
  /// Settings until it asks for access again, so the permission-problem screen asks when it
  /// appears. Asking doesn't change what the screen shows.
  @Test
  func permissionErrorScreenAsksTheSystem() async {
    let didRequestAccess = LockIsolated(false)

    let store = TestStore(
      initialState: .init(mode: .noAccessibilityPermission(.permissionError)),
      reducer: UserInterface.init
    ) {
      $0.accessibilityClient.requestAccess = {
        didRequestAccess.setValue(true)
      }
    }

    await store.send(.permissionErrorAppeared)
    await store.finish()
    #expect(didRequestAccess.value)
  }
}
