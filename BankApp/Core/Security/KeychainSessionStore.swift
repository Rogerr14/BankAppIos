import Foundation
import Security

struct StoredSession: Codable, Equatable {
    let accessToken: String
    let expiresAtUtc: Date
    let fullName: String
    let username: String

    var isExpired: Bool { expiresAtUtc <= Date() }
}

protocol SessionStoring {
    func save(_ session: StoredSession) throws
    func read() -> StoredSession?
    func delete()
}

final class KeychainSessionStore: SessionStoring {
    private let service = "com.rruiz.bankapp.session"
    private let account = "jwt-session"

    func save(_ session: StoredSession) throws {
        delete()
        let data = try JSONEncoder().encode(session)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else { throw APIError.unexpected }
    }

    func read() -> StoredSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(StoredSession.self, from: data)
    }

    func delete() {
        SecItemDelete([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account] as CFDictionary)
    }
}

