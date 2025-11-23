import SwiftUI

/// A button that opens Privacy & Security Settings when activated.
struct OpenPrivacyAndSecuritySettingsButton: View {
  @Environment(\.openURL) var openURL

  var body: some View {
    Button {
      // via https://stackoverflow.com/questions/52751941/how-to-launch-system-preferences-to-a-specific-preference-pane-using-bundle-iden
      openURL(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    } label: {
      let text = switch UserConfigurationName.current {
      case .preferences:
        "Open Security & Privacy Preferences → Accessibility"
      case .settings:
        "Open Privacy & Security Settings → Accessibility"
      }
      Text(text)
    }
  }
}
