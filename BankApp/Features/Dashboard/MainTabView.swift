import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Resumen", systemImage: "house.fill") }
            NavigationStack { AccountsView() }
                .tabItem { Label("Cuentas", systemImage: "creditcard.fill") }
            NavigationStack { ProfileView() }
                .tabItem { Label("Perfil", systemImage: "person.crop.circle.fill") }
        }
    }
}

