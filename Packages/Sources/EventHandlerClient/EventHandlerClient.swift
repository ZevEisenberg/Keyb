public struct EventHandlerClient {

    public var isEnabled: () -> Bool

    /// Attempt to start the event handler
    ///
    /// **Returns:** `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
    public var start: () -> Bool
    
    public var stop: () -> Void

    public init(
        isEnabled: @escaping () -> Bool,
        start: @escaping () -> Bool,
        stop: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.start = start
        self.stop = stop
    }
}

public extension EventHandlerClient {

    static func noop(enabled: Bool) -> Self {
        .init(
            isEnabled: { enabled },
            start: { true },
            stop: { }
        )
    }

}
