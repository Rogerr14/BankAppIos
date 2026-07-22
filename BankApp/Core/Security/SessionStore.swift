import Foundation

enum SessionState: Equatable {
    case resolving
    case signedOut
    case welcome(String)
    case authenticated
}

@MainActor
final class SessionStore: ObservableObject, AccessTokenProviding {
    @Published private(set) var state: SessionState = .resolving
    @Published private(set) var fullName = ""
    private let store: SessionStoring

    var isAuthenticated: Bool { state == .authenticated }
    var accessToken: String? { store.read()?.accessToken }

    init(store: SessionStoring) { self.store = store }

    func resolveInitialSession() async {
        guard let session = store.read(), !session.isExpired else {
            store.delete()
            try? await Task.sleep(for: .seconds(1))
            state = .signedOut
            return
        }
        fullName = session.fullName
        state = .welcome(session.fullName.firstName)
        try? await Task.sleep(for: .seconds(2))
        state = .authenticated
    }

    func start(_ response: LoginResponse) throws {
        let value = StoredSession(accessToken: response.accessToken, expiresAtUtc: response.expiresAtUtc, fullName: response.fullName, username: response.username)
        try store.save(value)
        fullName = response.fullName
        state = .authenticated
    }

    func logout() {
        store.delete()
        fullName = ""
        state = .signedOut
    }
}

