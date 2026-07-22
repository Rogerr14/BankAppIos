import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var container: AppContainer
    var body: some View {
        List {
            Section {
                HStack(spacing: 14) {
                    Image(systemName: "person.crop.circle.fill").font(.system(size: 54)).foregroundStyle(AppColors.brand)
                    VStack(alignment: .leading) { Text(session.fullName.isEmpty ? "Usuario BankApp" : session.fullName).font(.headline); Text("Perfil personal").foregroundStyle(AppColors.muted) }
                }.padding(.vertical, 8)
            }
            Section("Seguridad") {
                Label("Cambiar contraseña", systemImage: "lock")
                if container.biometricStore.hasCredentials {
                    Button(role: .destructive) { container.biometricStore.delete() } label: { Label("Desactivar acceso biométrico", systemImage: "faceid") }
                } else {
                    Label("Acceso biométrico no activado", systemImage: "faceid").foregroundStyle(AppColors.muted)
                }
            }
            Section {
                Button(role: .destructive) { session.logout() } label: { Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right") }
            }
        }.navigationTitle("Perfil")
    }
}
