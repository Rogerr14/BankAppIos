import XCTest
@testable import BankApp

final class APIErrorTests: XCTestCase {
    func testUnauthorizedHasReadableMessage() {
        XCTAssertEqual(APIError.unauthorized.errorDescription, "Tu sesión expiró. Inicia sesión nuevamente.")
    }
}
