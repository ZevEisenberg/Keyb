import ComposableArchitecture
import SwiftUI

struct EnableDisableView: View {

    @Perception.Bindable
    var store: StoreOf<UserInterface>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading) {
                Toggle(
                    isOn: $store.mode.isRunning.sending(\.changeObservingState)
                ) {
                    Text("Enable one-handed typing")
                }
                Text("Hold the space bar to mirror the keyboard horizontally. This allows you to type with one hand. Every time you would use the other hand, instead hold the spacebar and use the equivalent finger.")
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    EnableDisableView(
        store: .init(
            initialState: .init(mode: .hasAccessibilityPermission(isRunning: false)),
            reducer: AppFeature.init
        ) {
            $0.accessibilityClient = .accessibilityIsNotGranted
            $0.eventHandlerClient = .noop(enabled: false)
            $0.mainQueue = .immediate
        }
    )
    .frame(width: 400)
}
