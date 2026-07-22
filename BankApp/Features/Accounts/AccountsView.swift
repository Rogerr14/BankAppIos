import SwiftUI

struct AccountsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var accounts: [AccountSummary] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading { LoadingView() }
            else if let errorMessage { ContentUnavailableView("No pudimos cargar tus cuentas", systemImage: "exclamationmark.icloud", description: Text(errorMessage)) }
            else {
                List(accounts) { account in
                    NavigationLink { AccountDetailView(accountID: account.id) } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(account.title).font(.headline)
                            Text(account.maskedAccountNumber).font(.subheadline).foregroundStyle(AppColors.muted)
                            Text(account.availableBalance.usd).font(.title2.bold()).foregroundStyle(AppColors.brand)
                        }.padding(.vertical, 8)
                    }
                }.listStyle(.plain)
            }
        }
        .navigationTitle("Mis cuentas")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do { accounts = try await container.bankingService.accounts() }
        catch { errorMessage = error.localizedDescription }
    }
}

