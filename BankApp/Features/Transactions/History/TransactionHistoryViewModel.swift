import Foundation

@MainActor
final class TransactionHistoryViewModel: ObservableObject {
    @Published var filters = TransactionFilters()
    @Published private(set) var items: [TransactionItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var exportDocument: XLSXDocument?
    @Published var exportFileName = "transactions.xlsx"
    @Published var showsExporter = false
    private var page = 0
    private var hasNextPage = true
    private var activeRequest = false
    private var searchTask: Task<Void, Never>?

    func refresh(accountID: UUID, service: BankingService) async {
        guard filters.validationMessage == nil else { errorMessage = filters.validationMessage; return }
        page = 0; hasNextPage = true; items = []
        await loadMore(accountID: accountID, service: service)
    }

    func loadMore(accountID: UUID, service: BankingService) async {
        guard hasNextPage, !activeRequest else { return }
        activeRequest = true; isLoading = true
        defer { activeRequest = false; isLoading = false }
        do {
            let response = try await service.transactions(accountID: accountID, filters: filters, page: page + 1)
            items.append(contentsOf: response.items.filter { next in !items.contains(where: { $0.id == next.id }) })
            page = response.page; hasNextPage = response.hasNextPage; errorMessage = nil
        } catch { errorMessage = error.localizedDescription }
    }

    func searchChanged(accountID: UUID, service: BankingService) {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await refresh(accountID: accountID, service: service)
        }
    }

    func export(accountID: UUID, service: BankingService) async {
        guard let from = filters.dateFrom, let to = filters.dateTo else { errorMessage = "Selecciona las fechas desde y hasta para exportar."; return }
        guard from <= to else { errorMessage = "La fecha inicial no puede ser posterior a la fecha final."; return }
        let days = Calendar(identifier: .gregorian).dateComponents([.day], from: from, to: to).day ?? 0
        guard days <= 366 else { errorMessage = "El rango máximo de exportación es de 366 días."; return }
        isLoading = true; defer { isLoading = false }
        do {
            let file = try await service.exportTransactions(accountID: accountID, from: from, to: to, filters: filters)
            exportDocument = XLSXDocument(data: file.data); exportFileName = file.fileName; showsExporter = true
        } catch { errorMessage = error.localizedDescription }
    }
}
