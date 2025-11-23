import Carbon.HIToolbox

public struct Events {
  /// Events to post to the event tap before the main event.
  public let preEvents: [Unmanaged<CGEvent>]

  /// The main event to return from the event tap callback.
  public let mainEvent: Unmanaged<CGEvent>?

  /// All the events, in the order (`preEvents`, `mainEvent`)
  var all: [Unmanaged<CGEvent>] {
    (preEvents + [mainEvent]).compactMap(\.self)
  }

  public init(_ main: Unmanaged<CGEvent>?) {
    self.init(preEvents: [], mainEvent: main)
  }

  public init(
    preEvents: [Unmanaged<CGEvent>] = [],
    mainEvent: Unmanaged<CGEvent>? = nil
  ) {
    self.preEvents = preEvents
    self.mainEvent = mainEvent
  }
}

public final class KeyProcessor {
  private var isSpaceDown = false
  private var typedCharacterWhileSpaceWasDown = false
  private var nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown: Set<Int> = []

  public init() {}

  public func process(event: CGEvent, type: CGEventType) -> Events? {
    let unmodifiedEvent = { () -> Events? in
      let unmodified = Events(Unmanaged.passUnretained(event))
      return unmodified
    }
    let typedKeyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
    switch typedKeyCode {
    case kVK_Space:
      // If it's the spacebar, handle logic around flipping the keyboard or just typing a regular space
      if type == .keyDown {
        isSpaceDown = true
        if nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown.isEmpty {
          return nil
        } else {
          return unmodifiedEvent()
        }
      } else if type == .keyUp {
        isSpaceDown = false
        if typedCharacterWhileSpaceWasDown {
          typedCharacterWhileSpaceWasDown = false
          return nil
        } else if !nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown.isEmpty {
          nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown = []
          return unmodifiedEvent()
        } else {
          // simulate a key down so we type a space when space is released
          if let spaceDown = CGEvent(
            keyboardEventSource: CGEventSource(event: event),
            virtualKey: CGKeyCode(kVK_Space),
            keyDown: true
          ),
            let spaceUp = CGEvent(
              keyboardEventSource: CGEventSource(event: event),
              virtualKey: CGKeyCode(kVK_Space),
              keyDown: false
            )
          {
            return Events(
              preEvents: [Unmanaged.passRetained(spaceDown)],
              mainEvent: Unmanaged.passRetained(spaceUp)
            )
          } else {
            // fallback: return original event
            return unmodifiedEvent()
          }
        }
      }
      return unmodifiedEvent()
    default:
      defer {
        if event.type == .keyDown, !isSpaceDown {
          nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown.insert(typedKeyCode)
        }
      }

      if event.type == .keyUp, !isSpaceDown {
        nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown.remove(typedKeyCode)
      }

      let noOtherKeysCurrentlyPressed = nonFlippedNonSpaceKeysPressedBeforeOrDuringCurrentSpaceDown.isEmpty
      let otherKeysCurrentlyPressed = !noOtherKeysCurrentlyPressed
      if isSpaceDown, !otherKeysCurrentlyPressed {
        // Space is currently pressed, so flip the keyboard using the mapping table
        typedCharacterWhileSpaceWasDown = true

        // Get the flipped-layout character from the mapping table
        guard let newKeyCode = mapping[typedKeyCode] else {
          return unmodifiedEvent()
        }

        // Construct a new event, as though the user had typed the flipped key
        let newEvent = CGEvent(
          keyboardEventSource: CGEventSource(event: event),
          virtualKey: CGKeyCode(newKeyCode),
          keyDown: type == .keyDown
        )
        // fall back to original event if we failed to create a new one
        return newEvent.map(Unmanaged.passRetained).map(Events.init) ?? unmodifiedEvent()
      } else {
        // Space isn't down, so pass through the original keypress without changing it
        return unmodifiedEvent()
      }
    }
  }
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
