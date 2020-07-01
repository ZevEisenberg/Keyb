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

    private var eventTap: CFMachPort?

    // Lifecycle

    private init() {

    }

    func start() -> Bool {
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
        return true
    }

    func stop() {
        guard eventTap != nil else { return }
        // TODO: do this in Obj-C to catch thrown errors
        CFMachPortInvalidate(eventTap);
        eventTap = nil
    }

    func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        print(#function, event, event)
        // The incoming keycode.
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        if keyCode == kVK_Space {
            print("space")
        }

        guard let newKeyCode = mapping[keyCode] else {
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

}

private func eventTapCallback(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent, _ refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let handler = refcon?.assumingMemoryBound(to: EventHandler.self) else { return Unmanaged.passUnretained(event) }
    return handler.pointee.handle(event: event, type: type)
}

private let mapping: [Int64: Int64] = [
    Int64(kVK_ANSI_A): Int64(kVK_ANSI_Semicolon),
    Int64(kVK_ANSI_S): Int64(kVK_ANSI_L),
    Int64(kVK_ANSI_D): Int64(kVK_ANSI_K),
    Int64(kVK_ANSI_F): Int64(kVK_ANSI_J),
    Int64(kVK_ANSI_H): Int64(kVK_ANSI_G),
    Int64(kVK_ANSI_G): Int64(kVK_ANSI_H),
    Int64(kVK_ANSI_Z): Int64(kVK_ANSI_Slash),
    Int64(kVK_ANSI_X): Int64(kVK_ANSI_Period),
    Int64(kVK_ANSI_C): Int64(kVK_ANSI_Comma),
    Int64(kVK_ANSI_V): Int64(kVK_ANSI_M),
    Int64(kVK_ANSI_B): Int64(kVK_ANSI_N),
    Int64(kVK_ANSI_Q): Int64(kVK_ANSI_P),
    Int64(kVK_ANSI_W): Int64(kVK_ANSI_O),
    Int64(kVK_ANSI_E): Int64(kVK_ANSI_I),
    Int64(kVK_ANSI_R): Int64(kVK_ANSI_U),
    Int64(kVK_ANSI_Y): Int64(kVK_ANSI_T),
    Int64(kVK_ANSI_T): Int64(kVK_ANSI_Y),
    Int64(kVK_ANSI_O): Int64(kVK_ANSI_W),
    Int64(kVK_ANSI_U): Int64(kVK_ANSI_R),
    Int64(kVK_ANSI_I): Int64(kVK_ANSI_E),
    Int64(kVK_ANSI_P): Int64(kVK_ANSI_Q),
    Int64(kVK_ANSI_L): Int64(kVK_ANSI_S),
    Int64(kVK_ANSI_J): Int64(kVK_ANSI_F),
    Int64(kVK_ANSI_K): Int64(kVK_ANSI_D),
    Int64(kVK_ANSI_Semicolon): Int64(kVK_ANSI_A),
    Int64(kVK_ANSI_Comma): Int64(kVK_ANSI_C),
    Int64(kVK_ANSI_Slash): Int64(kVK_ANSI_Z),
    Int64(kVK_ANSI_N): Int64(kVK_ANSI_B),
    Int64(kVK_ANSI_M): Int64(kVK_ANSI_V),
    Int64(kVK_ANSI_Period): Int64(kVK_ANSI_X),
    // TODO: return, delete, punctuation, numbers
]
