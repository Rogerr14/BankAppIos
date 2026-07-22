import XCTest
@testable import BankApp

final class TransactionFiltersTests: XCTestCase {
    func testInvalidDateRange() {
        let filters = TransactionFilters(dateFrom: Date(timeIntervalSince1970: 200), dateTo: Date(timeIntervalSince1970: 100))
        XCTAssertNotNil(filters.validationMessage)
    }

    func testPageFiltersUseBackendNames() {
        let filters = TransactionFilters(transactionType: 1, direction: 2, status: 2, search: "Pago")
        XCTAssertEqual(Set(filters.queryItems.map(\.name)), Set(["TransactionType", "Direction", "Status", "Search"]))
    }
}
