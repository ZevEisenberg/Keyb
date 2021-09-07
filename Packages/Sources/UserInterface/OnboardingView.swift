import ComposableArchitecture
import SwiftUI

struct OnboardingView: View {

    let store: Store<UserInterfaceState, UserInterfaceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Text("Welcome to HalfKeyboard")
                    .font(.largeTitle)
                Text("Touch-type with one hand.")
                Spacer()
                Text("HalfKeyboard needs your permission to watch your keystrokes.")
                Button(action: { viewStore.send(.promptForPermission) }) {
                    Text("Grant Accessibility Permissions")
                }
                Spacer()
            }
            .padding()
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
        .previewLayout(.sizeThatFits)
    }
}
