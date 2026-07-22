import XCTest
@testable import BankApp

final class RegistrationValidatorTests: XCTestCase {
    func testValidRegistration() {
        XCTAssertNil(RegistrationValidator.validate(nationalID: "0123456789", firstNames: "Ana María", lastNames: "Pérez López", birthDate: Date(timeIntervalSince1970: 946684800), email: "ana@example.com", password: "SecurePass12!", confirmation: "SecurePass12!"))
    }

    func testRejectsPasswordContainingNationalID() {
        XCTAssertNotNil(RegistrationValidator.validate(nationalID: "0123456789", firstNames: "Ana", lastNames: "Pérez", birthDate: Date(timeIntervalSince1970: 946684800), email: "ana@example.com", password: "Abc!0123456789", confirmation: "Abc!0123456789"))
    }
}

