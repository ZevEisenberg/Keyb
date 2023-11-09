import AccessibilityClient
import Combine
import ComposableArchitecture
import EventHandlerClient
import UserInterface
import XCTest

@MainActor
final class UserInterfaceTests: XCTestCase {

    func testHappyPath() async {
        let mainQueue = DispatchQueue.test

        var currentlyTrusted = false
        let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

        let store = TestStore(
            initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
            reducer: AppFeature.init
        ) {
            $0.accessibilityClient = .init(isCurrentlyTrusted: { currentlyTrusted })
            $0.eventHandlerClient = .init(
                isEnabled: { eventHandlerIsRunning },
                startProvisional: {
                    currentlyTrusted = true
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

        await store.send(.checkForPermissions)
        await store.receive(.permissionChanged(hasAccessibilityPermission: false))

        await mainQueue.advance(by: 5)

        XCTAssertFalse(currentlyTrusted)

        // User grants permission. Doesn't really affect the test. Mostly here as documentation.
        currentlyTrusted = true

        await store.send(.permissionChanged(hasAccessibilityPermission: true)) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        await store.send(.changeObservingState(observing: true)) {
            $0.mode = .hasAccessibilityPermission(isRunning: true)
        }

        XCTAssertTrue(eventHandlerIsRunning.value)

        await store.send(.changeObservingState(observing: false)) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        XCTAssertFalse(eventHandlerIsRunning.value)
    }

    func testAlreadyHasPermission() async {
        let mainQueue = DispatchQueue.test

        let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

        let store = TestStore(
            initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
            reducer: AppFeature.init
        ) {
            $0.accessibilityClient = .init(isCurrentlyTrusted: { true })
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

        await store.send(.checkForPermissions)
        await store.receive(.permissionChanged(hasAccessibilityPermission: true))

        await mainQueue.advance(by: 5)

        await store.send(.changeObservingState(observing: true)) {
            $0.mode = .hasAccessibilityPermission(isRunning: true)
        }

        XCTAssertTrue(eventHandlerIsRunning.value)

        await store.send(.changeObservingState(observing: false)) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        XCTAssertFalse(eventHandlerIsRunning.value)
    }

}
