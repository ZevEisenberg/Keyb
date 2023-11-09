import Foundation

/// What does the current OS call it, System Preferences or System Settings?
enum UserConfigurationName {
    case preferences
    case settings

    static var current: Self {
        if ProcessInfo.processInfo.isOperatingSystemAtLeast(.init(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
            .settings
        } else {
            .preferences
        }
    }

    var settingsAppName: String {
        switch self {
        case .preferences:
            "System Preferences"
        case .settings:
            "System Settings"
        }
    }

    var privacyAndSecurityPaneName: String {
        switch self {
        case .preferences:
            "Security & Privacy"
        case .settings:
            "Privacy & Security"
        }
    }
}
