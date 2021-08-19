import Carbon.HIToolbox

public extension CGEventType {
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

