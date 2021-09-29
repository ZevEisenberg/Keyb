import ComposableArchitecture
import SwiftUI

struct EnableDisableView: View {

    let store: Store<UserInterfaceState, UserInterfaceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                Toggle(
                    isOn: viewStore.binding(
                        get: { userInterfaceState in
                            userInterfaceState.mode == .hasAccessibilityPermission(isRunning: true)
                        },
                        send: UserInterfaceAction.changeObservingState(observing:))
                ) {
                    Text("Enable one-handed typing")
                }
                Text("Hold the space bar to mirror the keyboard horizontally. This allows you to type with one hand. Every time you would use the other hand, instead hold the spacebar and use the equivalent finger.")
            }
        }
    }
}


struct EnableDisableView_Previews: PreviewProvider {
    static var previews: some View {
        EnableDisableView(
            store: .init(
                initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
                reducer: appReducer,
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
