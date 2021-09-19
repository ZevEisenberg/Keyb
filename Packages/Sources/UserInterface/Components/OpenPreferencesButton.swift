import SwiftUI

/// A button that opens Security & Privacy preferences when activated.
struct OpenPreferencesButton: View {

    @Environment(\.openURL) var openURL

    var body: some View {
        Button(action: {
            // via https://stackoverflow.com/questions/52751941/how-to-launch-system-preferences-to-a-specific-preference-pane-using-bundle-iden
            openURL(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!)
        }) {
            Text("Open Security & Privacy Preferences")
        }
    }
}
