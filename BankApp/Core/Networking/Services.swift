import Foundation

struct AuthService {
    let api: APIClient
    func login(username: String, password: String) async throws -> LoginResponse {
        try await api.send(.login(.init(username: username, password: password)))
    }
    func register(_ request: RegisterRequest) async throws -> RegisterResponse {
        try await api.send(.register(request))
    }
}

struct BankingService {
    let api: APIClient
    func dashboard() async throws -> DashboardResponse { try await api.send(.dashboard) }
    func accounts() async throws -> [AccountSummary] { try await api.send(.accounts) }
    func account(id: UUID) async throws -> AccountDetailResponse { try await api.send(.account(id: id)) }
    func transactions(accountID: UUID, filters: TransactionFilters = .init(), page: Int = 1) async throws -> PagedTransactions {
        try await api.send(.transactions(accountID: accountID, filters: filters, page: page))
    }
    func exportTransactions(accountID: UUID, from: Date, to: Date, filters: TransactionFilters = .init()) async throws -> DownloadedFile {
        let optionalFilters: [URLQueryItem] = [
            filters.transactionType.map { .init(name: "TransactionType", value: String($0)) },
            filters.direction.map { .init(name: "Direction", value: String($0)) },
            filters.status.map { .init(name: "Status", value: String($0)) }
        ].compactMap { $0 }
        return try await api.download(path: "/api/accounts/\(accountID)/transactions/export", queryItems: [
            .init(name: "DateFrom", value: from.apiDate),
            .init(name: "DateTo", value: to.apiDate)
        ] + optionalFilters)
    }
}
