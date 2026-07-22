import Foundation

enum RegistrationValidator {
    static func validate(nationalID: String, firstNames: String, lastNames: String, birthDate: Date, email: String, password: String, confirmation: String) -> String? {
        guard nationalID.count == 10, nationalID.allSatisfy(\.isNumber) else { return "La cédula debe tener exactamente 10 dígitos." }
        guard (2...100).contains(firstNames.trimmingCharacters(in: .whitespacesAndNewlines).count) else { return "Los nombres deben tener entre 2 y 100 caracteres." }
        guard (2...100).contains(lastNames.trimmingCharacters(in: .whitespacesAndNewlines).count) else { return "Los apellidos deben tener entre 2 y 100 caracteres." }
        guard birthDate <= Date() else { return "La fecha de nacimiento no puede ser futura." }
        guard email.count <= 150, email.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil else { return "Ingresa un correo electrónico válido." }
        guard (12...64).contains(password.count) else { return "La contraseña debe tener entre 12 y 64 caracteres." }
        guard password.range(of: "[A-Z]", options: .regularExpression) != nil,
              password.range(of: "[a-z]", options: .regularExpression) != nil,
              password.range(of: "[0-9]", options: .regularExpression) != nil,
              password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil else { return "Incluye mayúscula, minúscula, número y carácter especial." }
        guard !password.contains(where: \.isWhitespace) else { return "La contraseña no puede contener espacios." }
        guard !password.localizedCaseInsensitiveContains(nationalID) else { return "La contraseña no puede contener la cédula." }
        let localPart = email.split(separator: "@").first.map(String.init) ?? ""
        guard localPart.count < 3 || !password.localizedCaseInsensitiveContains(localPart) else { return "La contraseña no puede contener el nombre del correo." }
        guard password == confirmation else { return "Las contraseñas no coinciden." }
        return nil
    }
}
