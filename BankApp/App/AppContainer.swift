import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let session: SessionStore
    let api: APIClient
    let authService: AuthService
    let bankingService: BankingService
    let biometricStore: BiometricCredentialStore
    let biometricAuthenticator: BiometricAuthenticator

    init() {
        let tokenStore = KeychainSessionStore()
        let session = SessionStore(store: tokenStore)
        self.session = session
        self.api = APIClient(
            baseURL: AppEnvironment.current.baseURL,
            requestInterceptors: [AuthRequestInterceptor(tokenProvider: session)],
            responseInterceptors: [SessionResponseInterceptor(session: session)]
        )
        self.authService = AuthService(api: api)
        self.bankingService = BankingService(api: api)
        self.biometricStore = BiometricCredentialStore()
        self.biometricAuthenticator = BiometricAuthenticator()
    }
}
