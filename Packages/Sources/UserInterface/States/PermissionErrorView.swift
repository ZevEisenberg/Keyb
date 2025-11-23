import SwiftUI

struct PermissionErrorView: View {
  enum Mode {
    case awaiting
    case problem

    var title: String {
      switch self {
      case .awaiting:
        "Awaiting Accessibility Access"
      case .problem:
        "⚠️ Accessibility Access Issue"
      }
    }
  }

  let mode: Mode

  var body: some View {
    VStack(alignment: .leading) {
      Text(mode.title)
        .font(.headline)
      Text("Keyb needs your permission to watch your keystrokes in order to work.")
      Spacer()
        .frame(height: 10)

      let settingsAppName = UserConfigurationName.current.settingsAppName
      let paneName = UserConfigurationName.current.privacyAndSecurityPaneName

      AutoNumberingView { counter in
        Text("\(counter()). Open \(boldText(settingsAppName)) → \(boldText(paneName)):")
        OpenPrivacyAndSecuritySettingsButton()
        Text("\(counter()). Click on \(boldText("Accessibility")) if it is not already selected.")

        if UserConfigurationName.current == .preferences {
          // older versions of macOS have a lock icon, but newer ones do not
          Text("\(counter()). Click the 🔒 at the bottom to unlock it.")
        }

        switch UserConfigurationName.current {
        case .preferences:
          Text("\(counter()). Check the box next to Keyb.")
        case .settings:
          Text("\(counter()). Enable the switch next to Keyb.")
        }
      }
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}

private extension PermissionErrorView {
  func boldText(_ text: String) -> Text {
    Text(text).fontWeight(.bold)
  }
}

#Preview("Awaiting") {
  PermissionErrorView(mode: .awaiting)
    .frame(width: 400)
}

#Preview("Problem") {
  PermissionErrorView(mode: .problem)
    .frame(width: 400)
}
