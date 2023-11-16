import Combine
import Dependencies
import DependenciesMacros
import XCTestDynamicOverlay

@DependencyClient
public struct EventHandlerClient {

    public var isEnabled: () -> any Publisher<Bool, Never> = { Empty() }

    /// Attempt to start the event handler provisionally in order to force a system accessibility prompt.
    ///
    /// **Returns:** `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
    public var startProvisional: () -> Bool = { false }

    /// Attempt to start the event handler
    ///
    /// **Returns:** `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
    public var startActive: () -> Bool = { false }

    public var stop: () -> Void
}

public extension EventHandlerClient {

    static func noop(enabled: Bool) -> Self {
        .init(
            isEnabled: { CurrentValueSubject(enabled) },
            startProvisional: { true },
            startActive: { true },
            stop: { }
        )
    }

}

extension EventHandlerClient: TestDependencyKey {
    public static var testValue: Self {
        EventHandlerClient()
    }
}

public extension DependencyValues {
    var eventHandlerClient: EventHandlerClient {
        get { self[EventHandlerClient.self] }
        set { self[EventHandlerClient.self] = newValue }
    }
}
