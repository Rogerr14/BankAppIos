import SwiftUI

@main
struct BankAppApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(container.session)
                .tint(AppColors.brand)
        }
    }
}

