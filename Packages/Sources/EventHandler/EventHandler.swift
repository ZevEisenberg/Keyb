import Carbon.HIToolbox
import CoreGraphics
import Foundation
import HumanReadable
import KeyProcessor
import os.log

public extension Result where Success == Void {
    static func success() -> Self {
        .success(())
    }
}

private let keypressLog = OSLog(subsystem: "events", category: "keypresses")

public final class EventHandler {

    // Public Properties

    private(set) public var isEnabled = false

    // Private Properties

    private var eventTap: CFMachPort?
    private let keyProcessor = KeyProcessor()

    // Lifecycle

    public init() {}

    /// Attempt to start the event handler
    /// - Returns: `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
    public func start() -> Bool {
        guard !isEnabled else { return true }

        // Intercept keyDown, keyUp, and flagsChanged events
        let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue | 1 << CGEventType.flagsChanged.rawValue

        let callbackTrampoline: CGEventTapCallBack = { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) in
            guard let userInfo = userInfo else {
                return Unmanaged.passRetained(event)
            }
            let unsafeProcessor = Unmanaged<KeyProcessor>.fromOpaque(userInfo).takeUnretainedValue()

            #if DEBUG
            if #available(macOS 10.14, *) {
                // Log the key press in a privacy-preserving way for debugging purposes
                os_log(.debug, log: keypressLog, "0x%{private}.2X %@ flags: %@", UInt64(event.getIntegerValueField(.keyboardEventKeycode)), type.humanReadable, event.flags.humanReadable)

                // For when we can target macOS 11:
                // keypressLog.debug("0x\(UInt64(event.getIntegerValueField(.keyboardEventKeycode)), format: .hex, privacy: .private) \(type.humanReadable) flags: \(event.flags.humanReadable)")
            }
            #endif

            let events = unsafeProcessor.process(event: event, type: type)

            events?.preEvents.forEach { event in
                event.takeUnretainedValue().tapPostEvent(proxy)
            }

            return events?.mainEvent
        }

        // Set up the tap to intercept events
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callbackTrampoline,
            userInfo: Unmanaged.passUnretained(keyProcessor).toOpaque()
        )

        guard let eventTap = eventTap else {
            return false
        }

        // Enable the tap
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        isEnabled = true
        return true
    }

    public func stop() {
        guard eventTap != nil, isEnabled else { return }
        // TODO: do this in Obj-C to catch thrown errors
        CFMachPortInvalidate(eventTap);
        eventTap = nil
        isEnabled = false
    }

}