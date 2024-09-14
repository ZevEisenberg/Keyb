import Carbon.HIToolbox
import HumanReadable
import Testing

@testable import KeyProcessor

@Suite
struct KeyProcessorTests {

    @Test
    func lefRegularKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_ANSI_A, type: .keyDown, expected: [(kVK_ANSI_A, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_A, type: .keyUp, expected: [(kVK_ANSI_A, .keyUp)])
    }

    @Test
    func rightRegularKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_ANSI_O, type: .keyDown, expected: [(kVK_ANSI_O, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_O, type: .keyUp, expected: [(kVK_ANSI_O, .keyUp)])
    }

    @Test
    func spacebar() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyDown), (kVK_Space, .keyUp)])
    }

    @Test
    func leftFlippedKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_L, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_L, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [])
    }

    @Test
    func spaceWorksAfterCommandSpace() throws {
        let sut = KeyProcessor()

        // command-space shortcut
        try sut.assert(keyCode: kVK_Command, type: .keyDown, expected: [(kVK_Command, .flagsChanged)])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyDown), (kVK_Space, .keyUp)])
        try sut.assert(keyCode: kVK_Command, type: .keyUp, expected: [(kVK_Command, .flagsChanged)])

        // type a space
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyDown), (kVK_Space, .keyUp)])
    }

    @Test
    func typingSpaceWhileLetterIsPressedDown() throws {
        let sut = KeyProcessor()

        // Sometimes, when typing fast, we type a space while the last letter is still held down.
        // This should type the letter and the space, both on key-down.

        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_S, .keyDown)])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [(kVK_Space, .keyDown)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyUp)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_S, .keyUp)])
    }

    @Test
    func typingSpaceInterleavedWithLetter() throws {
        let sut = KeyProcessor()

        // Sometimes, when typing fast, we type a space while the last letter is still held down, and release them
        // in the same order. This should type the letter and the space, both on key-down.

        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_S, .keyDown)])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [(kVK_Space, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_S, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyUp)])
    }

    @Test
    func regularKeyThenFlippedKeyTwice() throws {
        let sut = KeyProcessor()

        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_S, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_S, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_L, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_L, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_L, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_L, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [])
    }

    @Test
    func delete() throws {
        let sut = KeyProcessor()

        // Type an S
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_S, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_S, .keyUp)])

        // Type Delete using Space-Tab
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Tab, type: .keyDown, expected: [(kVK_Delete, .keyDown)])
        try sut.assert(keyCode: kVK_Tab, type: .keyUp, expected: [(kVK_Delete, .keyUp)])

        // Type a flipped character
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_L, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_L, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [])

        // Type Delete using Space-Tab
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Tab, type: .keyDown, expected: [(kVK_Delete, .keyDown)])
        try sut.assert(keyCode: kVK_Tab, type: .keyUp, expected: [(kVK_Delete, .keyUp)])
    }
}

private enum EventType {
    case keyDown
    case keyUp

    var isKeyDown: Bool {
        switch self {
        case .keyDown: return true
        case .keyUp: return false
        }
    }

    var eventType: CGEventType {
        switch self {
        case .keyDown: return .keyDown
        case .keyUp: return .keyUp
        }
    }
}

private extension KeyProcessor {
    func assert(
        keyCode: Int,
        type: EventType,
        expected: [(keyCode: Int, type: CGEventType)],
        sourceLocation: Testing.SourceLocation = #_sourceLocation
    ) throws {
        let inputEvent = try #require(
            CGEvent(
                keyboardEventSource: CGEventSource(stateID: .hidSystemState),
                virtualKey: CGKeyCode(keyCode),
                keyDown: type.isKeyDown
            ).map(Unmanaged.passRetained),
            sourceLocation: sourceLocation
        )
        let events = process(event: inputEvent.takeUnretainedValue(), type: type.eventType)
        #expect(
            events?.all.count ?? 0 == expected.count,
            "expected \(expected.count) event(s), but got \(String(describing: events?.all.count))",
            sourceLocation: sourceLocation
        )

        for (testEventUnmanaged, controlEvent) in zip(events?.all ?? [], expected) {
            let testEvent = testEventUnmanaged.takeRetainedValue()
            #expect(testEvent.getIntegerValueField(.keyboardEventKeycode) == Int64(controlEvent.keyCode), "keycode not equal", sourceLocation: sourceLocation)
            #expect(testEvent.type.humanReadable == controlEvent.type.humanReadable, "event type not equal", sourceLocation: sourceLocation)
        }
    }
}
