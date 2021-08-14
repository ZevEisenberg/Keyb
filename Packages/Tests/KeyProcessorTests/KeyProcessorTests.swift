import Carbon.HIToolbox
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
        XCTExpectFailure("Spacebar is currently faking it by sending .keyDown when the user does a keyUp. Works because typing happens on key down, not key up, but it probably leaves the OS in a confused state because it thinks the spacebar is down. Will fix in a future change.")
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [(kVK_Space, .keyUp)])
    }

    func testLeftFlippedKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: [])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: [(kVK_ANSI_L, .keyDown)])
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: [(kVK_ANSI_L, .keyUp)])
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: [])
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

extension CGEventType {
    var humanReadable: String {
        switch self {
        case .null: return "null"
        case .leftMouseDown: return "leftMouseDown"
        case .leftMouseUp: return "leftMouseUp"
        case .rightMouseDown: return "rightMouseDown"
        case .rightMouseUp: return "rightMouseUp"
        case .mouseMoved: return "mouseMoved"
        case .leftMouseDragged: return "leftMouseDragged"
        case .rightMouseDragged: return "rightMouseDragged"
        case .keyDown: return "keyDown"
        case .keyUp: return "keyUp"
        case .flagsChanged: return "flagsChanged"
        case .scrollWheel: return "scrollWheel"
        case .tabletPointer: return "tabletPointer"
        case .tabletProximity: return "tabletProximity"
        case .otherMouseDown: return "otherMouseDown"
        case .otherMouseUp: return "otherMouseUp"
        case .otherMouseDragged: return "otherMouseDragged"
        case .tapDisabledByTimeout: return "tapDisabledByTimeout"
        case .tapDisabledByUserInput: return "tapDisabledByUserInput"
        @unknown default:
            return "unknown case \(self.rawValue)"
        }
    }
}
