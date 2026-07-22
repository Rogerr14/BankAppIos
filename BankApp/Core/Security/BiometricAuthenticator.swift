import Foundation
import LocalAuthentication

enum BiometricKind: Equatable {
    case none, faceID, touchID
    var title: String {
        switch self { case .faceID: "Face ID"; case .touchID: "Touch ID"; case .none: "Biometría" }
    }
}

protocol BiometricAuthenticating {
    func availability() -> (BiometricKind, String?)
    func authenticate(reason: String) async throws -> Bool
}

struct BiometricAuthenticator: BiometricAuthenticating {
    func availability() -> (BiometricKind, String?) {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return (.none, "Configura Face ID o Touch ID en Ajustes para habilitar esta opción.")
        }
        switch context.biometryType { case .faceID: return (.faceID, nil); case .touchID: return (.touchID, nil); default: return (.none, "Biometría no disponible.") }
    }

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { throw BiometricStoreError.unavailable }
        return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
    }
}
