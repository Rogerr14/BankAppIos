import Foundation
import LocalAuthentication
import Security

struct BiometricCredentials: Codable { let username: String; let password: String }

enum BiometricStoreError: Error { case unavailable, cancelled, invalidated, storage }

final class BiometricCredentialStore {
    private let service = "com.rruiz.bankapp.biometric-login"
    private let account = "credentials"

    var hasCredentials: Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecUseAuthenticationUI as String: kSecUseAuthenticationUIFail]
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess || metadataExists
    }

    private var metadataExists: Bool {
        UserDefaults.standard.bool(forKey: "biometricCredentialsEnabled")
    }

    func save(_ credentials: BiometricCredentials) throws {
        delete()
        var error: Unmanaged<CFError>?
        guard let control = SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .biometryCurrentSet, &error) else { throw BiometricStoreError.storage }
        let data = try JSONEncoder().encode(credentials)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account, kSecValueData as String: data, kSecAttrAccessControl as String: control]
        guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else { throw BiometricStoreError.storage }
        UserDefaults.standard.set(true, forKey: "biometricCredentialsEnabled")
    }

    func read(reason: String) throws -> BiometricCredentials {
        let context = LAContext()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context,
            kSecUseOperationPrompt as String: reason
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            if status == errSecUserCanceled || status == errSecAuthFailed { throw BiometricStoreError.cancelled }
            delete(); throw BiometricStoreError.invalidated
        }
        return try JSONDecoder().decode(BiometricCredentials.self, from: data)
    }

    func delete() {
        SecItemDelete([kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: service, kSecAttrAccount as String: account] as CFDictionary)
        UserDefaults.standard.removeObject(forKey: "biometricCredentialsEnabled")
    }
}
