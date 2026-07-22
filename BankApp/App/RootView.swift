import SwiftUI

struct RootView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            switch session.state {
            case .resolving: SplashView(message: nil)
            case .welcome(let name): SplashView(message: "Bienvenido, \(name)")
            case .signedOut: NavigationStack { LoginView(service: container.authService) }
            case .authenticated: MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.state)
        .task { if session.state == .resolving { await session.resolveInitialSession() } }
    }
}

