import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {

    let store: Store<UserInterfaceState, UserInterfaceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Text("Welcome to HalfKeyboard")
                    .font(.headline)
                Text("Touch-type with one hand.")
                    .font(.subheadline)
                Spacer()
                    .frame(height: 10)
                Text("HalfKeyboard needs your permission to watch your keystrokes:")
                Button(action: { viewStore.send(.promptForPermission) }) {
                    Text("Grant Accessibility Access")
                }
                Text("Privacy info: we never collect, store, or transmit anything you type. All text processing is done locally on your computer.")
                    .font(.subheadline)
            }
            .fixedSize(horizontal: false, vertical: true)

        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(
            store: .init(
                initialState: .init(mode: .noAccessibilityPermission(.hasNotPromptedYet)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .accessibilityIsNotGranted,
                    eventHandlerClient: .noop(enabled: false),
                    mainQueue: .immediate
                )
            )
        )
        .frame(width: 400)
    }
}
