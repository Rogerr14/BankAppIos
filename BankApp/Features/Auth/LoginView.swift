import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: LoginViewModel
    private let service: AuthService

    init(service: AuthService) {
        self.service = service
        _viewModel = StateObject(wrappedValue: LoginViewModel(service: service))
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppColors.brand.ignoresSafeArea().frame(height: 210)
            ScrollView {
                VStack(spacing: 24) {
                    header
                    loginCard
                }.padding(.horizontal, 20)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "building.columns.fill").font(.system(size: 42)).foregroundStyle(.white)
            Text("BANKAPP").font(.title2.bold()).foregroundStyle(.white)
            Text(AppEnvironment.current == .dev ? "Ambiente de desarrollo" : "Banca segura")
                .font(.caption).foregroundStyle(.white.opacity(0.8))
        }.padding(.top, 18)
    }

    private var loginCard: some View {
        VStack(spacing: 18) {
            Text("¡Hola!").font(.largeTitle.bold()).foregroundStyle(AppColors.ink)
            Text("Ingresa a tu banca móvil").foregroundStyle(AppColors.muted)
            TextField("Usuario o cédula", text: $viewModel.username)
                .textContentType(.username).keyboardType(.numberPad).bankTextField()
            passwordField
            if let error = viewModel.errorMessage { ErrorBanner(message: error) }
            Button { Task { await normalLogin() } } label: {
                if viewModel.isLoading { ProgressView().tint(.white) } else { Text("Continuar") }
            }.buttonStyle(PrimaryButtonStyle()).disabled(viewModel.isLoading)
            biometricOption
            if container.biometricStore.hasCredentials && biometricKind != .none { biometricLoginButton }
            NavigationLink("¿Necesitas crear un usuario?") { RegisterView(service: service) }
                .font(.subheadline.bold()).foregroundStyle(AppColors.brand)
            Button("Recuperar contraseña") { }
                .font(.caption).foregroundStyle(AppColors.muted)
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
    }

    private var passwordField: some View {
        HStack {
            Group {
                if viewModel.isPasswordVisible { TextField("Contraseña", text: $viewModel.password) }
                else { SecureField("Contraseña", text: $viewModel.password) }
            }.textContentType(.password)
            Button { viewModel.isPasswordVisible.toggle() } label: {
                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye").foregroundStyle(AppColors.muted)
            }.accessibilityLabel(viewModel.isPasswordVisible ? "Ocultar contraseña" : "Mostrar contraseña")
        }.bankTextField()
    }

    private var biometricKind: BiometricKind { container.biometricAuthenticator.availability().0 }

    private var biometricOption: some View {
        let availability = container.biometricAuthenticator.availability()
        return VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $viewModel.enableBiometrics) {
                Label("Activar \(availability.0.title)", systemImage: availability.0 == .faceID ? "faceid" : "touchid")
            }.disabled(availability.0 == .none)
            if let reason = availability.1 { Text(reason).font(.caption).foregroundStyle(AppColors.muted) }
        }.padding(14).background(AppColors.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private var biometricLoginButton: some View {
        Button {
            Task { await viewModel.biometricLogin(session: session, credentialStore: container.biometricStore, biometricName: biometricKind.title) }
        } label: {
            Label("Ingresar con \(biometricKind.title)", systemImage: biometricKind == .faceID ? "faceid" : "touchid")
        }.buttonStyle(.bordered).controlSize(.large).tint(AppColors.brand)
    }

    private func normalLogin() async {
        await viewModel.login(session: session)
        guard session.isAuthenticated, viewModel.enableBiometrics else { return }
        if (try? await container.biometricAuthenticator.authenticate(reason: "Confirma la activación del acceso biométrico")) == true {
            try? container.biometricStore.save(.init(username: viewModel.username, password: viewModel.password))
        }
        viewModel.password = ""
    }
}
