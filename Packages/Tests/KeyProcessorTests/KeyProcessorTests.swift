import Carbon.HIToolbox
import HumanReadable
import XCTest
@testable import KeyProcessor

final class KeyProcessorTests: XCTestCase {

    func testLefRegularKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_ANSI_A, type: .keyDown, expected: [(kVK_ANSI_A, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_A, type: .keyUp, expected: [(kVK_ANSI_A, .keyUp)])
    }

    func testRightRegularKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_ANSI_O, type: .keyDown, expected: [(kVK_ANSI_O, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_O, type: .keyUp, expected: [(kVK_ANSI_O, .keyUp)])
    }

    func testSpacebar() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyDown), (kVK_Space, .keyUp)])
    }

    func testLeftFlippedKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_L, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_L, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [])
    }

    func testSpaceWorksAfterCommandSpace() throws {
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

    func testTypingSpaceWhileLetterIsPressedDown() throws {
        let sut = KeyProcessor()

        // Sometimes, when typing fast, we type a space while the last letter is still held down.
        // This should type the letter and the space, both on key-down.

        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_S, .keyDown)])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [(kVK_Space, .keyDown)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyUp)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_S, .keyUp)])
    }

    func testTypingSpaceInterleavedWithLetter() throws {
        let sut = KeyProcessor()

        // Sometimes, when typing fast, we type a space while the last letter is still held down, and release them
        // in the same order. This should type the letter and the space, both on key-down.

        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_S, .keyDown)])
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [(kVK_Space, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_S, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyUp)])
    }

    func testRegularKeyThenFlippedKeyTwice() throws {
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

    func testDelete() throws {
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
    func assert(keyCode: Int, type: EventType, expected: [(keyCode: Int, type: CGEventType)], file: StaticString = #filePath, line: UInt = #line) throws {
        let inputEvent = try XCTUnwrap(
            CGEvent(
                keyboardEventSource: CGEventSource(stateID: .hidSystemState),
                virtualKey: CGKeyCode(keyCode),
                keyDown: type.isKeyDown
            ).map(Unmanaged.passRetained)
        )
        let events = process(event: inputEvent.takeUnretainedValue(), type: type.eventType)
        XCTAssertEqual(
            events?.all.count ?? 0, expected.count,
            "expected \(expected.count) event(s), but got \(String(describing: events?.all.count))",
            file: file, line: line
        )

        for (testEventUnmanaged, controlEvent) in zip(events?.all ?? [], expected) {
            let testEvent = testEventUnmanaged.takeRetainedValue()
            XCTAssertEqual(testEvent.getIntegerValueField(.keyboardEventKeycode), Int64(controlEvent.keyCode), "keycode not equal", file: file, line: line)
            XCTAssertEqual(testEvent.type.humanReadable, controlEvent.type.humanReadable, "event type not equal", file: file, line: line)
        }
    }
}
