import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = AccountDetailViewModel()
    let accountID: UUID

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.detail == nil { LoadingView() }
            else if let detail = viewModel.detail { detailContent(detail) }
            else { ContentUnavailableView("Cuenta no disponible", systemImage: "creditcard.trianglebadge.exclamationmark", description: Text(viewModel.errorMessage ?? "Intenta nuevamente.")) }
        }
        .navigationTitle("Cuenta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.brand, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await viewModel.load(accountID: accountID, service: container.bankingService) }
    }

    private func detailContent(_ detail: AccountDetailResponse) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Image(systemName: "banknote.fill").font(.title); Spacer(); Text("Disponible").font(.caption) }
                    Text(detail.availableBalance.usd).font(.system(size: 36, weight: .bold))
                    Text("Cuenta de \(detail.accountType == 2 ? "corriente" : "ahorros")")
                    Text("•••• \(detail.accountNumber.suffix(4))").font(.subheadline)
                }
                .foregroundStyle(.white).padding(22).frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(colors: [AppColors.brand, AppColors.brandDark], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))

                HStack {
                    balance("Contable", detail.ledgerBalance)
                    Divider()
                    balance("Retenido", detail.heldBalance)
                }.frame(height: 58).padding().background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))

                HStack {
                    Label(detail.status == 1 ? "Activa" : detail.status == 2 ? "Bloqueada" : "Cerrada", systemImage: "checkmark.shield")
                    Spacer()
                    VStack(alignment: .trailing) { Text("Apertura").font(.caption).foregroundStyle(AppColors.muted); Text(detail.openedAtUtc.displayDate).font(.subheadline.weight(.semibold)) }
                }.padding().background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))

                HStack { Text("Movimientos").font(.title2.bold()); Spacer(); Image(systemName: "line.3.horizontal.decrease.circle").foregroundStyle(AppColors.brand) }
                NavigationLink { TransactionHistoryView(accountID: accountID) } label: {
                    Label("Ver historial completo", systemImage: "list.bullet.rectangle").frame(maxWidth: .infinity)
                }.buttonStyle(.bordered).tint(AppColors.brand)
                if viewModel.transactions.isEmpty { Text("No hay movimientos para mostrar.").foregroundStyle(AppColors.muted).padding(.vertical, 30) }
                ForEach(viewModel.transactions) { item in
                    TransactionRow(description: item.description, date: item.occurredAtUtc, amount: item.amount, isCredit: item.direction == 1, balanceAfter: item.balanceAfter)
                        .onAppear { if item.id == viewModel.transactions.last?.id { Task { await viewModel.loadMore(accountID: accountID, service: container.bankingService) } } }
                }
                if viewModel.isLoading { ProgressView().tint(AppColors.brand) }
            }.padding(20)
        }
    }

    private func balance(_ title: String, _ value: Decimal) -> some View {
        VStack { Text(title).font(.caption).foregroundStyle(AppColors.muted); Text(value.usd).font(.headline) }.frame(maxWidth: .infinity)
    }
}
