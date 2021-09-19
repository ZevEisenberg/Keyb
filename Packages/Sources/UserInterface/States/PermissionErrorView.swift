import SwiftUI

struct PermissionErrorView: View {

    enum Mode {
        case awaiting
        case problem

        var title: String {
            switch self {
            case .awaiting:
                return "Awaiting Accessibility Access"
            case .problem:
                return "⚠️ Accessibility Access Issue"
            }
        }
    }

    let mode: Mode

    var body: some View {
        VStack(alignment: .leading) {
            Text(mode.title)
                .font(.largeTitle)
            Text("HalfKeyboard needs your permission to watch your keystrokes in order to work.")
            Spacer()
                .frame(height: 10)
            Text("1. Open \(boldText("System Preferences")) → \(boldText("Security & Privacy")):")
            OpenPreferencesButton()
            Text("2. Click on \(boldText("Accessibility")).")
            Text("3. Click the 🔒 at the bottom to unlock it.")
            Text("4. Check the box next to HalfKeyboard.")
        }
        .fixedSize(horizontal: false, vertical: true)
    }

}

private extension PermissionErrorView {
    func boldText(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) -> Text {
        Text(key, tableName: tableName, bundle: bundle, comment: comment).fontWeight(.bold)
    }
}

struct PermissionsErrorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PermissionErrorView(mode: .awaiting)

            PermissionErrorView(mode: .problem)
        }
        .frame(width: 400)
    }
}
