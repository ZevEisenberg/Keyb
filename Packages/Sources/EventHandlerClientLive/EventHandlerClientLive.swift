import EventHandler
import EventHandlerClient

public extension EventHandlerClient {

    static func live(with eventHandler: EventHandler) -> Self {
        .init(
            isEnabled: {
                eventHandler.isEnabled
            },
            startProvisional: { eventHandler.start(mode: .provisional )},
            startActive: { eventHandler.start(mode: .active) },
            stop: eventHandler.stop
        )
    }

}
