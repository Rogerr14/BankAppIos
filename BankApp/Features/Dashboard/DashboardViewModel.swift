import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var dashboard: DashboardResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(using service: BankingService) async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do { dashboard = try await service.dashboard() }
        catch { errorMessage = error.localizedDescription }
    }
}

