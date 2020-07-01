//
//  EventHandler.swift
//  HalfKeyboard
//
//  Created by Zev Eisenberg on 7/1/20.
//

import Foundation
import CoreGraphics

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

        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: mask, callback: eventTapCallback(_:_:_:_:), userInfo: Unmanaged.passUnretained(self).toOpaque())

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
        print("key code:", keyCode)

        let lowercaseD = 2 as CGKeyCode
        let new = CGEvent(keyboardEventSource: CGEventSource(event: event), virtualKey: lowercaseD, keyDown: type == .keyDown)
        return new.map(Unmanaged.passRetained)
    }

}

private func eventTapCallback(_ proxy: CGEventTapProxy, _ type: CGEventType, _ event: CGEvent, _ refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let handler = refcon?.assumingMemoryBound(to: EventHandler.self) else { return Unmanaged.passUnretained(event) }
    return handler.pointee.handle(event: event, type: type)
}

