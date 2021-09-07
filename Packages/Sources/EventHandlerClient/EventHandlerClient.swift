public struct EventHandlerClient {

    public var isEnabled: () -> Bool

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
        isEnabled: @escaping () -> Bool,
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
            isEnabled: { enabled },
            startProvisional: { true },
            startActive: { true },
            stop: { }
        )
    }

}
