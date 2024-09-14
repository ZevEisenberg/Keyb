import AccessibilityClient
import Combine
import ComposableArchitecture
import EventHandlerClient
import UserInterface
import Testing
import Dispatch

@MainActor
@Suite
struct UserInterfaceTests {

    @Test
    func happyPath() async {
        let mainQueue = DispatchQueue.test

        let currentlyTrusted = LockIsolated(false)
        let eventHandlerIsRunning: CurrentValueSubject<Bool, Never> = .init(false)

        let store = TestStore(
            initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
            reducer: AppFeature.init
        ) {
            $0.accessibilityClient = .init(isCurrentlyTrusted: { currentlyTrusted.value })
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

}
