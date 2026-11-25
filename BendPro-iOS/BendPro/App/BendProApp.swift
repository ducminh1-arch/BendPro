import SwiftUI
import BendProCore

@main
struct BendProApp: App {
    @StateObject private var appStore = AppStore()

    var body: some Scene {
        WindowGroup {
            MainShellView(appStore: appStore)
                .preferredColorScheme(.dark)
        }
    }
}
