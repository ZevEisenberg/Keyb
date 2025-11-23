import Carbon.HIToolbox
import Combine
import CoreGraphics
import Foundation
import HumanReadable
import KeyProcessor
import os.log

private let keypressLog = Logger(subsystem: "events", category: "keypresses")

@MainActor
public final class EventHandler {
  public enum Mode {
    /// Start a tap in order to prompt for accessibility permissions, and then shut off again
    case provisional

    /// Intercept keystrokes to enable one-handed typing
    case active
  }

  // Public Properties

  /// Whether we are currently intercepting and modifying keystrokes.
  public var isEnabled: any Publisher<Bool, Never> {
    isEnabledGuts
  }

  // Private Properties

  private var isEnabledGuts: CurrentValueSubject<Bool, Never> = .init(false)
  private var eventTap: CFMachPort?
  private let keyProcessor = KeyProcessor()

  // Lifecycle

  public nonisolated init() {}

  /// Attempt to start the event handler
  /// - Returns: `true` if successfully started. Otherwise, `false`, probably due to a permissions error.
  public func start(mode: Mode) -> Bool {
    guard !isEnabledGuts.value else {
      return true
    }

    // Intercept keyDown, keyUp, and flagsChanged events
    let mask: CGEventMask = 1 << CGEventType.keyDown.rawValue | 1 << CGEventType.keyUp.rawValue | 1 << CGEventType.flagsChanged.rawValue

    let callbackTrampoline: CGEventTapCallBack = { (proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, userInfo: UnsafeMutableRawPointer?) in
      guard let userInfo else {
        return Unmanaged.passRetained(event)
      }
      let unsafeProcessor = Unmanaged<KeyProcessor>.fromOpaque(userInfo).takeUnretainedValue()

      #if DEBUG
      // Log the key press in a privacy-preserving way for debugging purposes
      keypressLog.debug("0x\(UInt64(event.getIntegerValueField(.keyboardEventKeycode)), format: .hex, privacy: .private) \(type.humanReadable) flags: \(event.flags.humanReadable)")
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

    guard let eventTap else {
      return false
    }

    // Enable the tap
    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, CFRunLoopMode.commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    isEnabledGuts.value = true

    if mode == .provisional {
      stop()
    }
    return true
  }

  public func stop() {
    guard eventTap != nil, isEnabledGuts.value else {
      return
    }
    // TODO: do this in Obj-C to catch thrown errors
    CFMachPortInvalidate(eventTap)
    eventTap = nil
    isEnabledGuts.value = false
  }
}
