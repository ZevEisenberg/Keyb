//
//  EventHandler.swift
//  HalfKeyboard
//
//  Created by Zev Eisenberg on 7/1/20.
//

import Foundation
import CoreGraphics
import Carbon.HIToolbox

final class EventHandler {

    // Public Properties

    static let shared = EventHandler()

    // Private Properties

    private var isRunning = false
    private var eventTap: CFMachPort?
    private var isSpaceDown: Bool = false
    private var typedCharacterWhileSpaceWasDown: Bool = false

    // Lifecycle

    private init() {

    }

    func start() -> Bool {
        guard !isRunning else { return true }
        let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue | 1 << CGEventType.flagsChanged.rawValue

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: eventTapCallback(_:_:_:_:),
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap = eventTap else {
            print("Permission issue")
            return false
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        isRunning = true
        return true
    }

    func stop() {
        guard eventTap != nil, isRunning else { return }
        // TODO: do this in Obj-C to catch thrown errors
        CFMachPortInvalidate(eventTap);
        eventTap = nil
        isRunning = false
    }

    func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        let typedKeyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        switch typedKeyCode {
        case kVK_Space:
            if type == .keyDown {
                if isSpaceDown { return nil }
                isSpaceDown = true
                return nil
            }
            else if type == .keyUp {
                isSpaceDown = false
                if typedCharacterWhileSpaceWasDown {
                    typedCharacterWhileSpaceWasDown = false
                    return nil
                }
                else {
                    // simulate a key down so we type a space when space is released
                    return CGEvent(
                        keyboardEventSource: CGEventSource(event: event),
                        virtualKey: CGKeyCode(kVK_Space),
                        keyDown: true
                    ).map(Unmanaged.passRetained) ?? Unmanaged.passUnretained(event)
                }
            }
            return Unmanaged.passUnretained(event)
        default:
            if isSpaceDown {
                typedCharacterWhileSpaceWasDown = true
                guard let newKeyCode = mapping[typedKeyCode] else {
                    return Unmanaged.passUnretained(event)
                }

                let newEvent = CGEvent(
                    keyboardEventSource: CGEventSource(event: event),
                    virtualKey: CGKeyCode(newKeyCode),
                    keyDown: type == .keyDown
                )
                // fall back to original event if we failed to create a new one
                return newEvent.map(Unmanaged.passRetained) ?? Unmanaged.passUnretained(event)
            }
            else {
                return Unmanaged.passUnretained(event)
            }
        }
    }

}

private func eventTapCallback(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent, _ refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let handler = refcon?.assumingMemoryBound(to: EventHandler.self) else { return Unmanaged.passUnretained(event) }
    return handler.pointee.handle(event: event, type: type)
}

private let mapping: [Int: Int] = [
    kVK_ANSI_A: kVK_ANSI_Semicolon,
    kVK_ANSI_S: kVK_ANSI_L,
    kVK_ANSI_D: kVK_ANSI_K,
    kVK_ANSI_F: kVK_ANSI_J,
    kVK_ANSI_H: kVK_ANSI_G,
    kVK_ANSI_G: kVK_ANSI_H,
    kVK_ANSI_Z: kVK_ANSI_Slash,
    kVK_ANSI_X: kVK_ANSI_Period,
    kVK_ANSI_C: kVK_ANSI_Comma,
    kVK_ANSI_V: kVK_ANSI_M,
    kVK_ANSI_B: kVK_ANSI_N,
    kVK_ANSI_Q: kVK_ANSI_P,
    kVK_ANSI_W: kVK_ANSI_O,
    kVK_ANSI_E: kVK_ANSI_I,
    kVK_ANSI_R: kVK_ANSI_U,
    kVK_ANSI_Y: kVK_ANSI_T,
    kVK_ANSI_T: kVK_ANSI_Y,
    kVK_ANSI_O: kVK_ANSI_W,
    kVK_ANSI_U: kVK_ANSI_R,
    kVK_ANSI_I: kVK_ANSI_E,
    kVK_ANSI_P: kVK_ANSI_Q,
    kVK_ANSI_L: kVK_ANSI_S,
    kVK_ANSI_J: kVK_ANSI_F,
    kVK_ANSI_K: kVK_ANSI_D,
    kVK_ANSI_Semicolon: kVK_ANSI_A,
    kVK_ANSI_Comma: kVK_ANSI_C,
    kVK_ANSI_Slash: kVK_ANSI_Z,
    kVK_ANSI_N: kVK_ANSI_B,
    kVK_ANSI_M: kVK_ANSI_V,
    kVK_ANSI_Period: kVK_ANSI_X,
    kVK_Tab: kVK_Delete,
    kVK_ANSI_Backslash: kVK_Tab,

    // Top row
    kVK_ANSI_Grave: kVK_ANSI_Minus,
    kVK_ANSI_1: kVK_ANSI_0,
    kVK_ANSI_2: kVK_ANSI_9,
    kVK_ANSI_3: kVK_ANSI_8,
    kVK_ANSI_4: kVK_ANSI_7,
    kVK_ANSI_5: kVK_ANSI_6,
    kVK_ANSI_6: kVK_ANSI_5,
    kVK_ANSI_7: kVK_ANSI_4,
    kVK_ANSI_8: kVK_ANSI_3,
    kVK_ANSI_9: kVK_ANSI_2,
    kVK_ANSI_0: kVK_ANSI_1,
    kVK_ANSI_Minus: kVK_ANSI_Grave,
    kVK_ANSI_Equal: kVK_ANSI_Grave,

    // TODO: punctuation, caps lock, return
]
