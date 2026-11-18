import ComposableArchitecture
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
  let store: StoreOf<UserInterface>

  var body: some View {
    VStack(alignment: .leading) {
      Text(mode.title)
        .font(.headline)
      Text("Keyb needs your permission to watch your keystrokes in order to work.")
      Spacer()
        .frame(height: 10)

      // No button: the system's Accessibility alert doesn't come back once the user has answered
      // it, and there's no way to tell whether it appeared, so describe the path instead.
      // TODO: #46. This path is wrong on macOS 27.2.1, where the pane is Privacy & Security →
      // Device Control and Data Access. Other versions are unchecked.
      // TODO: #54. If Keyb was removed from the list, there's no switch to enable, and these steps
      // don't help.
      AutoNumberingView { counter in
        Text("\(counter()). Open \(boldText("System Settings")) → \(boldText("Privacy & Security")).")
        Text("\(counter()). Click on \(boldText("Accessibility")).")
        Text("\(counter()). Enable the switch next to Keyb.")
      }
    }
    .fixedSize(horizontal: false, vertical: true)
    .task {
      if mode == .problem {
        store.send(.permissionErrorAppeared)
      }
    }
  }
}

private extension PermissionErrorView {
  func boldText(_ text: String) -> Text {
    Text(text).fontWeight(.bold)
  }
}

#Preview("Awaiting") {
  PermissionErrorView(
    mode: .awaiting,
    store: .init(
      initialState: .init(mode: .noAccessibilityPermission(.awaitingUser)),
      reducer: UserInterface.init
    )
  )
  .frame(width: 400)
}

#Preview("Problem") {
  PermissionErrorView(
    mode: .problem,
    store: .init(
      initialState: .init(mode: .noAccessibilityPermission(.permissionError)),
      reducer: UserInterface.init
    )
  )
  .frame(width: 400)
}
