import SwiftUI

enum AppColors {
    static let brand = Color(red: 0.86, green: 0.00, blue: 0.43)
    static let brandDark = Color(red: 0.67, green: 0.00, blue: 0.34)
    static let ink = Color.primary
    static let muted = Color.secondary
    static let surface = Color(uiColor: .secondarySystemBackground)
    static let success = Color(red: 0.00, green: 0.72, blue: 0.40)
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(AppColors.brand.opacity(configuration.isPressed ? 0.75 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct BankTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

extension View {
    func bankTextField() -> some View { modifier(BankTextFieldStyle()) }
}
