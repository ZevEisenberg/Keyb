import EventHandler
import EventHandlerClient
import Dependencies

public extension EventHandlerClient {

    static func live(with eventHandler: EventHandler) -> Self {
        .init(
            isEnabled: {
                eventHandler.isEnabled
            },
            startProvisional: { eventHandler.start(mode: .provisional) },
            startActive: { eventHandler.start(mode: .active) },
            stop: eventHandler.stop
        )
    }

}

extension EventHandlerClient: DependencyKey {
    public static let liveValue = EventHandlerClient.live(with: EventHandler())
}
