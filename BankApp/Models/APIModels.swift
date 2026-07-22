import Foundation

struct ServiceResult<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let errors: [String]
}

struct EmptyResponse: Decodable {}

struct LoginRequest: Encodable { let username: String; let password: String }

struct RegisterRequest: Encodable {
    let nationalId: String
    let firstNames: String
    let lastNames: String
    let dateOfBirth: String
    let email: String
    let password: String
    let confirmPassword: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresAtUtc: Date
    let userAccountId: UUID
    let username: String
    let fullName: String
}

struct RegisterResponse: Decodable {
    let userAccountId: UUID
    let username: String
    let fullName: String
}

struct AccountSummary: Decodable, Identifiable {
    let id: UUID
    let maskedAccountNumber: String
    let accountType: Int
    let currency: Int
    let status: Int
    let availableBalance: Decimal
    let ledgerBalance: Decimal
    let heldBalance: Decimal

    var title: String { accountType == 2 ? "Cuenta corriente" : "Cuenta de ahorros" }
}

struct TransactionItem: Decodable, Identifiable {
    let id: UUID
    let reference: String
    let description: String
    let transactionType: Int
    let direction: Int
    let status: Int
    let amount: Decimal
    let balanceAfter: Decimal
    let occurredAtUtc: Date
}

struct DashboardTransaction: Decodable, Identifiable {
    let id: UUID
    let accountId: UUID
    let maskedAccountNumber: String
    let reference: String
    let transactionType: Int
    let direction: Int
    let status: Int
    let description: String
    let amount: Decimal
    let occurredAtUtc: Date
}

struct DashboardResponse: Decodable {
    let fullName: String
    let lastLoginAtUtc: Date?
    let totalAvailableBalance: Decimal
    let accounts: [AccountSummary]
    let latestTransactions: [DashboardTransaction]
}

struct AccountDetailResponse: Decodable {
    let id: UUID
    let accountNumber: String
    let accountType: Int
    let currency: Int
    let status: Int
    let availableBalance: Decimal
    let ledgerBalance: Decimal
    let heldBalance: Decimal
    let openedAtUtc: Date
    let createdAtUtc: Date
    let updatedAtUtc: Date?
    let latestTransactions: [TransactionItem]
}

struct PagedTransactions: Decodable {
    let items: [TransactionItem]
    let page: Int
    let pageSize: Int
    let totalItems: Int
    let totalPages: Int
    let hasPreviousPage: Bool
    let hasNextPage: Bool
}

