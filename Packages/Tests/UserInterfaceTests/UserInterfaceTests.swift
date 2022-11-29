import AccessibilityClient
import Combine
import ComposableArchitecture
import EventHandlerClient
import UserInterface
import XCTest

final class UserInterfaceTests: XCTestCase {

    func testHappyPath() {
        let mainQueue = DispatchQueue.test

        var currentlyTrusted = false
        let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

        let store = TestStore(
            initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
            reducer: AppFeature(),
            prepareDependencies: {
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
        )

        store.send(.checkForPermissions)
        store.receive(.permissionChanged(hasAccessibilityPermission: false))

        mainQueue.advance(by: 5)

        XCTAssertFalse(currentlyTrusted)

        // User grants permission. Doesn't really affect the test. Mostly here as documentation.
        currentlyTrusted = true

        store.send(.permissionChanged(hasAccessibilityPermission: true)) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        store.send(.changeObservingState(observing: true)) {
            $0.mode = .hasAccessibilityPermission(isRunning: true)
        }

        XCTAssertTrue(eventHandlerIsRunning.value)

        store.send(.changeObservingState(observing: false)) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        XCTAssertFalse(eventHandlerIsRunning.value)
    }

    func testAlreadyHasPermission() {
        let mainQueue = DispatchQueue.test

        let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

        let store = TestStore(
            initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
            reducer: AppFeature(),
            prepareDependencies: {
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
        )

        store.send(.checkForPermissions)
        store.receive(.permissionChanged(hasAccessibilityPermission: true))

        mainQueue.advance(by: 5)

        store.send(.changeObservingState(observing: true)) {
            $0.mode = .hasAccessibilityPermission(isRunning: true)
        }

        XCTAssertTrue(eventHandlerIsRunning.value)

        store.send(.changeObservingState(observing: false)) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        XCTAssertFalse(eventHandlerIsRunning.value)
    }

}
