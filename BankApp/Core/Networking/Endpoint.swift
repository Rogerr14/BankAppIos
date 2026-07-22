import Foundation

enum HTTPMethod: String { case get = "GET", post = "POST" }

struct Endpoint<Response: Decodable> {
    let path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var body: Encodable?
    var requiresAuth = true
}

extension Endpoint {
    static func login(_ request: LoginRequest) -> Endpoint<LoginResponse> {
        .init(path: "/api/auth/login", method: .post, body: request, requiresAuth: false)
    }

    static func register(_ request: RegisterRequest) -> Endpoint<RegisterResponse> {
        .init(path: "/api/auth/register", method: .post, body: request, requiresAuth: false)
    }

    static var dashboard: Endpoint<DashboardResponse> { .init(path: "/api/dashboard") }
    static var accounts: Endpoint<[AccountSummary]> { .init(path: "/api/accounts") }
    static func account(id: UUID) -> Endpoint<AccountDetailResponse> { .init(path: "/api/accounts/\(id)") }
    static func transactions(accountID: UUID, filters: TransactionFilters = .init(), page: Int = 1, pageSize: Int = 20) -> Endpoint<PagedTransactions> {
        .init(path: "/api/accounts/\(accountID)/transactions", queryItems: filters.queryItems + [
            .init(name: "Page", value: String(page)), .init(name: "PageSize", value: String(pageSize))
        ])
    }
}
