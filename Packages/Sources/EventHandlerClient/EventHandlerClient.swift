import Combine
import Dependencies
import XCTestDynamicOverlay

public struct EventHandlerClient {

    public var isEnabled: () -> CurrentValueSubject<Bool, Never>

    /// Attempt to start the event handler provisionally in order to force a system accessibility prompt.
    ///
    /// **Returns:** `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
    public var startProvisional: () -> Bool

    /// Attempt to start the event handler
    ///
    /// **Returns:** `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
    public var startActive: () -> Bool
    
    public var stop: () -> Void

    public init(
        isEnabled: @escaping () -> CurrentValueSubject<Bool, Never>,
        startProvisional: @escaping () -> Bool,
        startActive: @escaping () -> Bool,
        stop: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.startProvisional = startProvisional
        self.startActive = startActive
        self.stop = stop
    }
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

    static var unimplemented: Self {
        EventHandlerClient(
            isEnabled: XCTUnimplemented("\(Self.self).isEnabled", placeholder: CurrentValueSubject<Bool, Never>(false)),
            startProvisional: XCTUnimplemented("\(Self.self).startProvisional"),
            startActive: XCTUnimplemented("\(Self.self).startActive", placeholder: false),
            stop: XCTUnimplemented("\(Self.self).startActive", placeholder: ())
        )
    }

}

extension EventHandlerClient: TestDependencyKey {
    public static let testValue = EventHandlerClient.unimplemented
}

public extension DependencyValues {
    var eventHandlerClient: EventHandlerClient {
        get { self[EventHandlerClient.self] }
        set { self[EventHandlerClient.self] = newValue }
    }
}
