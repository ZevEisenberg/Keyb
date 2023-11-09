import ComposableArchitecture
import SwiftUI

struct EnableDisableView: View {

    let store: StoreOf<UserInterface>

    var body: some View {
        WithViewStore(store, observe: \.mode) { viewStore in
            VStack(alignment: .leading) {
                Toggle(
                    isOn: viewStore.binding(
                        get: { mode in
                            mode == .hasAccessibilityPermission(isRunning: true)
                        },
                        send: UserInterface.Action.changeObservingState(observing:))
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
                reducer: AppFeature()
                    .dependency(\.accessibilityClient, .accessibilityIsNotGranted)
                    .dependency(\.eventHandlerClient, .noop(enabled: false))
                    .dependency(\.mainQueue, .immediate)
            )
        )
        .frame(width: 400)
    }
}
