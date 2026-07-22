import SwiftUI

struct SplashView: View {
    let message: String?
    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.brand, AppColors.brandDark], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "building.columns.fill").font(.system(size: 64)).foregroundStyle(.white)
                Text("BANKAPP").font(.largeTitle.bold()).foregroundStyle(.white)
                if let message { Text(message).font(.title3.weight(.semibold)).foregroundStyle(.white.opacity(0.9)) }
                else { ProgressView().tint(.white) }
            }
        }.accessibilityElement(children: .combine).accessibilityLabel(message ?? "Cargando BankApp")
    }
}
