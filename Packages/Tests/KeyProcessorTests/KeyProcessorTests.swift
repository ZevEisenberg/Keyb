import Carbon.HIToolbox
import XCTest
@testable import KeyProcessor

final class KeyProcessorTests: XCTestCase {

    func testLefRegularKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_ANSI_A, type: .keyDown, expected: (kVK_ANSI_A, .keyDown))
        try sut.assert(keyCode: kVK_ANSI_A, type: .keyUp, expected: (kVK_ANSI_A, .keyUp))
    }

    func testRightRegularKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_ANSI_O, type: .keyDown, expected: (kVK_ANSI_O, .keyDown))
        try sut.assert(keyCode: kVK_ANSI_O, type: .keyUp, expected: (kVK_ANSI_O, .keyUp))
    }

    func testSpacebar() throws {
        XCTExpectFailure("Spacebar is currently faking it by sending .keyDown when the user does a keyUp. Works because typing happens on key down, not key up, but it probably leaves the OS in a confused state because it thinks the spacebar is down. Will fix in a future change.")
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: nil)
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: (kVK_Space, .keyUp))
    }

    func testLeftFlippedKeyDown() throws {
        let sut = KeyProcessor()
        try sut.assert(keyCode: kVK_Space, type: .keyDown, expected: nil)
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyDown, expected: (kVK_ANSI_L, .keyDown))
        try sut.assert(keyCode: kVK_ANSI_S, type: .keyUp, expected: (kVK_ANSI_L, .keyUp))
        try sut.assert(keyCode: kVK_Space, type: .keyUp, expected: nil)
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
    func assert(keyCode: Int, type: EventType, expected: (keyCode: Int, type: CGEventType)?, file: StaticString = #filePath, line: UInt = #line) throws {
        let fakeEvent = try XCTUnwrap(
            CGEvent(
                keyboardEventSource: CGEventSource(stateID: .hidSystemState),
                virtualKey: CGKeyCode(keyCode),
                keyDown: type.isKeyDown
            ).map(Unmanaged.passRetained)
        )
        let event = process(event: fakeEvent.takeUnretainedValue(), type: type.eventType)?.takeRetainedValue()
        if let expected = expected {
            if let event = event {
                XCTAssertEqual(event.getIntegerValueField(.keyboardEventKeycode), Int64(expected.keyCode), "keycode not equal", file: file, line: line)
                XCTAssertEqual(event.type.humanReadable, expected.type.humanReadable, "event type not equal", file: file, line: line)
            }
            else {
                XCTFail("Got nil, but expected \(expected)")
            }
        }
        else {
            XCTAssertNil(event)
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
