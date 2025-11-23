import Dependencies
import EventHandler
import EventHandlerClient

public extension EventHandlerClient {
  nonisolated static func live(with eventHandler: EventHandler) -> Self {
    .init(
      isEnabled: {
        eventHandler.isEnabled
      },
      startProvisional: { eventHandler.start(mode: .provisional) },
      startActive: { eventHandler.start(mode: .active) },
      stop: { eventHandler.stop() }
    )
  }
}

extension EventHandlerClient: DependencyKey {
  public static var liveValue: Self {
    EventHandlerClient.live(with: EventHandler())
  }
}
