import ComposableArchitecture
import SwiftUI

struct EnableDisableView: View {

    let store: Store<UserInterfaceState, UserInterfaceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Toggle(
                    isOn: viewStore.binding(
                        get: { userInterfaceState in
                            userInterfaceState.mode == .hasAccessibilityPermission(isRunning: true)
                        },
                        send: { newValue in
                            if newValue {
                                return UserInterfaceAction.promptForPermission
                            } else {
                                return .stopObservingEvents
                            }
                        })
                ) {
                    Text("Enable half keyboard")
                }
                Text("When this box is checked, holding the space bar will flip the keyboard horizontally. This allows you to type with one hand. Every time you would use the other hand, instead hold the spacebar and use the equivalent finger.")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(width: 400)
        }
    }
}


struct EnableDisableView_Previews: PreviewProvider {
    static var previews: some View {
        EnableDisableView(
            store: .init(
                initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
                reducer: userInterfaceReducer,
                environment: .init(
                    accessibilityClient: .grantsWhenPrompted,
                    eventHandlerClient: .noop(enabled: false)
                )
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
