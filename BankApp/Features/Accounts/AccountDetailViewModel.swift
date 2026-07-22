import Foundation

@MainActor
final class AccountDetailViewModel: ObservableObject {
    @Published var detail: AccountDetailResponse?
    @Published var transactions: [TransactionItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var page = 1
    @Published var hasNextPage = false

    func load(accountID: UUID, service: BankingService) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            async let detailRequest = service.account(id: accountID)
            async let transactionsRequest = service.transactions(accountID: accountID)
            let (detail, result) = try await (detailRequest, transactionsRequest)
            self.detail = detail; transactions = result.items; hasNextPage = result.hasNextPage; page = result.page
        } catch { errorMessage = error.localizedDescription }
    }

    func loadMore(accountID: UUID, service: BankingService) async {
        guard hasNextPage, !isLoading else { return }
        isLoading = true; defer { isLoading = false }
        do {
            let result = try await service.transactions(accountID: accountID, page: page + 1)
            transactions.append(contentsOf: result.items); page = result.page; hasNextPage = result.hasNextPage
        } catch { errorMessage = error.localizedDescription }
    }
}

