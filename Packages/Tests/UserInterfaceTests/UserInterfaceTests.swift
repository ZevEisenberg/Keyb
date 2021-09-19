import AccessibilityClient
import ComposableArchitecture
import EventHandlerClient
import UserInterface
import XCTest

final class UserInterfaceTests: XCTestCase {

    func testHappyPath() {
        let mainQueue = DispatchQueue.test

        var currentlyTrusted = false
        var eventHandlerIsRunning = false

        let store = TestStore(
            initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
            reducer: userInterfaceReducer,
            environment: .init(
                accessibilityClient: .init(isCurrentlyTrusted: {
                    currentlyTrusted
                }),
                eventHandlerClient: .init(
                    isEnabled: { eventHandlerIsRunning },
                    startProvisional: {
                        currentlyTrusted = true
                        return true
                    },
                    startActive: {
                        eventHandlerIsRunning = true
                        return true
                    },
                    stop: {
                        eventHandlerIsRunning = false
                    }
                ),
                mainQueue: mainQueue.eraseToAnyScheduler()
            )
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

        store.send(.startObservingEvents) {
            $0.mode = .hasAccessibilityPermission(isRunning: true)
        }

        XCTAssertTrue(eventHandlerIsRunning)

        store.send(.stopObservingEvents) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        XCTAssertFalse(eventHandlerIsRunning)
    }

    func testAlreadyHasPermission() {
        let mainQueue = DispatchQueue.test

        var eventHandlerIsRunning = false

        let store = TestStore(
            initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
            reducer: userInterfaceReducer,
            environment: .init(
                accessibilityClient: .init(isCurrentlyTrusted: { true }),
                eventHandlerClient: .init(
                    isEnabled: { eventHandlerIsRunning },
                    startProvisional: { true },
                    startActive: {
                        eventHandlerIsRunning = true
                        return true
                    },
                    stop: {
                        eventHandlerIsRunning = false
                    }
                ),
                mainQueue: mainQueue.eraseToAnyScheduler()
            )
        )

        store.send(.checkForPermissions)
        store.receive(.permissionChanged(hasAccessibilityPermission: true))

        mainQueue.advance(by: 5)

        store.send(.startObservingEvents) {
            $0.mode = .hasAccessibilityPermission(isRunning: true)
        }

        XCTAssertTrue(eventHandlerIsRunning)

        store.send(.stopObservingEvents) {
            $0.mode = .hasAccessibilityPermission(isRunning: false)
        }

        XCTAssertFalse(eventHandlerIsRunning)
    }

}
