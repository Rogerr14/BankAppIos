import XCTest
@testable import BankApp

final class BankingEnumsTests: XCTestCase {
    func testUnknownValuesArePreserved() {
        XCTAssertEqual(AccountType(99), .unknown(99))
        XCTAssertEqual(TransactionDirection(8), .unknown(8))
        XCTAssertEqual(TransactionStatus(10), .unknown(10))
    }
}

