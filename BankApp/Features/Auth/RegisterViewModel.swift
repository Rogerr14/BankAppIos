import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var nationalId = ""
    @Published var firstNames = ""
    @Published var lastNames = ""
    @Published var birthDate = Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didRegister = false
    private let service: AuthService

    init(service: AuthService) { self.service = service }

    func register() async {
        if let validation = RegistrationValidator.validate(nationalID: nationalId, firstNames: firstNames, lastNames: lastNames, birthDate: birthDate, email: email, password: password, confirmation: confirmPassword) {
            errorMessage = validation; return
        }
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        do {
            _ = try await service.register(.init(nationalId: nationalId, firstNames: firstNames, lastNames: lastNames, dateOfBirth: formatter.string(from: birthDate), email: email, password: password, confirmPassword: confirmPassword))
            didRegister = true
        } catch { errorMessage = error.localizedDescription }
    }
}
