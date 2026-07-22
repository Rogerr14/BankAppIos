import Foundation

extension Decimal {
    var usd: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: self as NSDecimalNumber) ?? "$0.00"
    }
}

extension String {
    var firstName: String { split(separator: " ").first.map(String.init) ?? self }
}
