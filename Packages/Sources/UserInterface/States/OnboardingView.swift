import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {

    let store: StoreOf<UserInterface>

    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to Keyb")
                .font(.headline)
            Text("Touch-type with one hand.")
                .font(.subheadline)
            Spacer()
                .frame(height: 10)
            Text("Keyb needs your permission to watch your keystrokes:")
            Button(action: { store.send(.promptForPermission) }) {
                Text("Grant Accessibility Access")
            }
            Text("Privacy info: we never collect, store, or transmit anything you type. All text processing is done locally on your computer.")
                .font(.subheadline)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    OnboardingView(
        store: .init(
            initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
            reducer: AppFeature.init
        ) {
            $0.accessibilityClient = .accessibilityIsNotGranted
            $0.eventHandlerClient = .noop(enabled: false)
            $0.mainQueue = .immediate
        }
    )
    .frame(width: 400)
}
