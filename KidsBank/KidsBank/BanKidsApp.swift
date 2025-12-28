import SwiftUI
import ComposableArchitecture

@main
struct BanKidsApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppFeature.State()
                ) {
                    AppFeature()
                }
            )
        }
    }
}
