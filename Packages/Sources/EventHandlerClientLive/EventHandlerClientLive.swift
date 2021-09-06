import EventHandler
import EventHandlerClient

public extension EventHandlerClient {

    static func live(with eventHandler: EventHandler) -> Self {
        .init(
            isEnabled: {
                eventHandler.isEnabled
            },
            start: eventHandler.start,
            stop: eventHandler.stop
        )
    }

}
