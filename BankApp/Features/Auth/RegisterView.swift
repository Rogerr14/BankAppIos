import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RegisterViewModel
    init(service: AuthService) { _viewModel = StateObject(wrappedValue: RegisterViewModel(service: service)) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Crea tu cuenta").font(.largeTitle.bold())
                Text("Completa tus datos personales").foregroundStyle(AppColors.muted)
                field("Cédula", text: $viewModel.nationalId, keyboard: .numberPad)
                field("Nombres", text: $viewModel.firstNames)
                field("Apellidos", text: $viewModel.lastNames)
                BankDateField(title: "Fecha de nacimiento", selection: Binding(get: { viewModel.birthDate }, set: { if let value = $0 { viewModel.birthDate = value } }), allowedRange: Date(timeIntervalSince1970: -2_208_988_800)...Date(), isRequired: true, allowsClear: false)
                field("Correo electrónico", text: $viewModel.email, keyboard: .emailAddress)
                SecureField("Contraseña", text: $viewModel.password).bankTextField()
                SecureField("Confirmar contraseña", text: $viewModel.confirmPassword).bankTextField()
                Text("Mínimo 12 caracteres, mayúscula, minúscula, número y carácter especial.")
                    .font(.caption).foregroundStyle(AppColors.muted)
                if let error = viewModel.errorMessage { ErrorBanner(message: error) }
                Button { Task { await viewModel.register() } } label: {
                    if viewModel.isLoading { ProgressView().tint(.white) } else { Text("Crear usuario") }
                }.buttonStyle(PrimaryButtonStyle())
            }.padding(22)
        }
        .navigationTitle("Registro").navigationBarTitleDisplayMode(.inline)
        .alert("Usuario creado", isPresented: $viewModel.didRegister) {
            Button("Ir al inicio") { dismiss() }
        } message: { Text("Ya puedes iniciar sesión con tu número de cédula.") }
    }

    private func field(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(title, text: text).keyboardType(keyboard).textInputAutocapitalization(.never).bankTextField()
    }
}
