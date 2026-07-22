import Foundation

struct TransactionFilters: Equatable {
    var dateFrom: Date?
    var dateTo: Date?
    var transactionType: Int?
    var direction: Int?
    var status: Int?
    var search = ""

    var queryItems: [URLQueryItem] {
        [
            dateFrom.map { URLQueryItem(name: "DateFrom", value: $0.apiDate) },
            dateTo.map { URLQueryItem(name: "DateTo", value: $0.apiDate) },
            transactionType.map { URLQueryItem(name: "TransactionType", value: String($0)) },
            direction.map { URLQueryItem(name: "Direction", value: String($0)) },
            status.map { URLQueryItem(name: "Status", value: String($0)) },
            search.isEmpty ? nil : URLQueryItem(name: "Search", value: search)
        ].compactMap { $0 }
    }

    var validationMessage: String? {
        guard let from = dateFrom, let to = dateTo else { return nil }
        return from > to ? "La fecha inicial no puede ser posterior a la fecha final." : nil
    }
}
