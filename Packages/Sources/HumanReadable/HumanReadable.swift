import Carbon.HIToolbox

public extension CGEventType {
  var humanReadable: String {
    switch self {
    case .null:
      "null"
    case .leftMouseDown:
      "leftMouseDown"
    case .leftMouseUp:
      "leftMouseUp"
    case .rightMouseDown:
      "rightMouseDown"
    case .rightMouseUp:
      "rightMouseUp"
    case .mouseMoved:
      "mouseMoved"
    case .leftMouseDragged:
      "leftMouseDragged"
    case .rightMouseDragged:
      "rightMouseDragged"
    case .keyDown:
      "keyDown"
    case .keyUp:
      "keyUp"
    case .flagsChanged:
      "flagsChanged"
    case .scrollWheel:
      "scrollWheel"
    case .tabletPointer:
      "tabletPointer"
    case .tabletProximity:
      "tabletProximity"
    case .otherMouseDown:
      "otherMouseDown"
    case .otherMouseUp:
      "otherMouseUp"
    case .otherMouseDragged:
      "otherMouseDragged"
    case .tapDisabledByTimeout:
      "tapDisabledByTimeout"
    case .tapDisabledByUserInput:
      "tapDisabledByUserInput"
    @unknown default:
      "unknown case \(rawValue)"
    }
  }
}

public extension CGEventFlags {
  var humanReadable: String {
    let names: KeyValuePairs<CGEventFlags, String> = [
      .maskAlphaShift: "Caps Lock",
      .maskShift: "Shift",
      .maskControl: "Control",
      .maskAlternate: "Option",
      .maskCommand: "Command",
      .maskHelp: "Help",
      .maskSecondaryFn: "Fn",
      .maskNumericPad: "Number Pad",
      .maskNonCoalesced: "Non-Coalesced",
    ]

    return names
      .compactMap { flag, name in self.contains(flag) ? name : nil }
      .joined(separator: " ")
  }
}
