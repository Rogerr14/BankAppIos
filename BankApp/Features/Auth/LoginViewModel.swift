import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isPasswordVisible = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var enableBiometrics = false
    private let service: AuthService

    init(service: AuthService) { self.service = service }

    func login(session: SessionStore) async {
        guard !username.isEmpty, !password.isEmpty else { errorMessage = "Ingresa tu usuario y contraseña."; return }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do { try session.start(try await service.login(username: username, password: password)) }
        catch { errorMessage = error.localizedDescription }
    }

    func biometricLogin(session: SessionStore, credentialStore: BiometricCredentialStore, biometricName: String) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let credentials = try credentialStore.read(reason: "Ingresa con \(biometricName)")
            let response = try await service.login(username: credentials.username, password: credentials.password)
            try session.start(response)
        } catch BiometricStoreError.cancelled {
            errorMessage = nil
        } catch {
            let credentialsWereRejected: Bool = {
                guard let apiError = error as? APIError else { return false }
                if apiError == .unauthorized { return true }
                if case .server(let status, _) = apiError { return status == 401 }
                return false
            }()
            if credentialsWereRejected {
                credentialStore.delete()
                errorMessage = "Tus credenciales cambiaron. Inicia sesión nuevamente."
            } else { errorMessage = error.localizedDescription }
        }
    }
}
