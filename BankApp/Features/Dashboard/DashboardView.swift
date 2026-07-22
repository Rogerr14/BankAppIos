import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.dashboard == nil { LoadingView() }
            else if let dashboard = viewModel.dashboard { content(dashboard) }
            else { ContentUnavailableView("Sin información", systemImage: "wifi.exclamationmark", description: Text(viewModel.errorMessage ?? "Intenta nuevamente.")) }
        }
        .navigationBarHidden(true)
        .task { if viewModel.dashboard == nil { await viewModel.load(using: container.bankingService) } }
        .refreshable { await viewModel.load(using: container.bankingService) }
    }

    private func content(_ dashboard: DashboardResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hola,").foregroundStyle(AppColors.muted)
                        Text(dashboard.fullName.firstName).font(.largeTitle.bold()).foregroundStyle(AppColors.brand)
                    }
                    Spacer()
                    Image(systemName: "bell").font(.title2)
                    Image(systemName: "person.crop.circle.fill").font(.title).foregroundStyle(AppColors.brand)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Saldo total disponible").font(.subheadline).foregroundStyle(.white.opacity(0.85))
                    Text(dashboard.totalAvailableBalance.usd).font(.system(size: 34, weight: .bold)).foregroundStyle(.white)
                }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [AppColors.brand, AppColors.brandDark], startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 22))
                Text("Cuentas").font(.title2.bold())
                if dashboard.accounts.isEmpty {
                    Text("No tienes cuentas registradas.").foregroundStyle(AppColors.muted)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(dashboard.accounts) { account in
                                NavigationLink { AccountDetailView(accountID: account.id) } label: { AccountCard(account: account) }
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }
                LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 14) {
                    QuickAction(icon: "arrow.left.arrow.right", title: "Transferir", subtitle: "Entre cuentas")
                    QuickAction(icon: "doc.text.fill", title: "Movimientos", subtitle: "Revisa tu historial")
                    QuickAction(icon: "target", title: "Metas", subtitle: "Organiza tus ahorros")
                    QuickAction(icon: "chart.pie.fill", title: "Mis finanzas", subtitle: "Controla tus gastos")
                }
                Text("Últimos movimientos").font(.title2.bold())
                ForEach(dashboard.latestTransactions.prefix(5)) { transaction in
                    TransactionRow(description: transaction.description, date: transaction.occurredAtUtc, amount: transaction.amount, isCredit: transaction.direction == 1)
                }
            }.padding(20)
        }
    }
}

private struct AccountCard: View {
    let account: AccountSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { Image(systemName: "banknote.fill").font(.title); Spacer(); Image(systemName: "eye") }
            Spacer()
            Text(account.availableBalance.usd).font(.title.bold())
            Text("\(account.title) \(account.maskedAccountNumber)").font(.subheadline)
        }
        .foregroundStyle(.white).padding(20).frame(width: 270, height: 180)
        .background(LinearGradient(colors: [AppColors.brand, AppColors.brandDark], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct QuickAction: View {
    let icon: String; let title: String; let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).font(.title2).foregroundStyle(AppColors.brand)
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(AppColors.muted)
        }.frame(maxWidth: .infinity, minHeight: 110, alignment: .leading).padding(16).background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18)).shadow(color: .black.opacity(0.05), radius: 12, y: 5)
    }
}

struct TransactionRow: View {
    let description: String; let date: Date; let amount: Decimal; let isCredit: Bool; var balanceAfter: Decimal? = nil
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCredit ? "arrow.down.left" : "arrow.up.right")
                .foregroundStyle(isCredit ? AppColors.success : AppColors.brand)
                .frame(width: 40, height: 40).background(AppColors.surface, in: Circle())
            VStack(alignment: .leading) {
                Text(description).font(.subheadline.weight(.semibold)).lineLimit(1)
                Text(date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(AppColors.muted)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(isCredit ? "+" : "-")\(amount.usd)").font(.subheadline.bold()).foregroundStyle(isCredit ? AppColors.success : AppColors.ink)
                if let balanceAfter { Text("Saldo \(balanceAfter.usd)").font(.caption2).foregroundStyle(AppColors.muted) }
            }
        }.padding(14).background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}
