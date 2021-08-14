import Carbon.HIToolbox
import CoreGraphics
import Foundation
import KeyProcessor

final class EventHandler {

    // Public Properties

    static let shared = EventHandler()

    // Private Properties

    private var isRunning = false
    private var eventTap: CFMachPort?
    private let keyProcessor = KeyProcessor()

    // Lifecycle

    private init() {

    }

    func start() -> Bool {
        guard !isRunning else { return true }

        // Intercept keyDown, keyUp, and flagsChanged events
        let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue | 1 << CGEventType.flagsChanged.rawValue

        let callbackTrampoline: CGEventTapCallBack = { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) in
            guard let userInfo = userInfo else {
                return Unmanaged.passRetained(event)
            }
            let unsafeProcessor = Unmanaged<KeyProcessor>.fromOpaque(userInfo).takeUnretainedValue()
            let events = unsafeProcessor.process(event: event, type: type)
            events?.extras.forEach { event in
                DispatchQueue.main.async {
                    event.takeRetainedValue().post(tap: .cgSessionEventTap)
                }
            }
            return events?.main
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
            print("Permission issue")
            return false
        }

        // Enable the tap
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

}
