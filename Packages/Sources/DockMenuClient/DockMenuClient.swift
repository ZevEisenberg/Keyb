import Combine
import ComposableArchitecture

public struct DockMenuClient {

    public var isRunning: () -> Effect<Bool, Never>
    public var updateIsRunning: (Bool) -> Effect<Void, Never>

    public init(
        isRunning: @escaping () -> Effect<Bool, Never>,
        updateIsRunning: @escaping (Bool) -> Effect<Void, Never>
    ) {
        self.isRunning = isRunning
        self.updateIsRunning = updateIsRunning
    }

    public static func noop(isRunning: Bool) -> Self {
        .init(
            isRunning: { .init(value: isRunning) },
            updateIsRunning: { _ in .none }
        )
    }
}
