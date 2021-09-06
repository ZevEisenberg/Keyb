import SwiftUI

struct PermissionErrorView: View {

    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Permission Issue ⚠️")
                    .font(.largeTitle)
                Text("HalfKeyboard needs your permission to watch your keystrokes in order to work.")
                Spacer()
                Text("1. Open \(boldText("System Preferences")) → \(boldText("Security & Privacy")):")
                openPreferencesButton
                Text("2. Click on \(boldText("Accessibility")).")
                Text("3. Click the 🔒 at the bottom to unlock it.")
                Text("4. Check the box next to HalfKeyboard.")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }

    var openPreferencesButton: some View {
        Button(action: {
            // via https://stackoverflow.com/questions/52751941/how-to-launch-system-preferences-to-a-specific-preference-pane-using-bundle-iden
            openURL(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
        }) {
            Text("Open Security & Privacy Preferences")
        }
    }

}

private extension PermissionErrorView {
    func boldText(_ key: LocalizedStringKey, tableName: String? = nil, bundle: Bundle? = nil, comment: StaticString? = nil) -> Text {
        Text(key, tableName: tableName, bundle: bundle, comment: comment).fontWeight(.bold)
    }
}

struct PermissionsErrorView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionErrorView()
            .frame(width: 400, height: 400)
    }
}
