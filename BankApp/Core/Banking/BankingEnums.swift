import Foundation

enum AccountType: Equatable { case savings, checking, unknown(Int); init(_ value: Int) { self = value == 1 ? .savings : value == 2 ? .checking : .unknown(value) } }
enum AccountStatus: Equatable { case active, blocked, closed, unknown(Int); init(_ value: Int) { switch value { case 1: self = .active; case 2: self = .blocked; case 3: self = .closed; default: self = .unknown(value) } } }
enum TransactionDirection: Equatable { case credit, debit, unknown(Int); init(_ value: Int) { self = value == 1 ? .credit : value == 2 ? .debit : .unknown(value) } }
enum TransactionStatus: Equatable { case pending, completed, rejected, reversed, unknown(Int); init(_ value: Int) { switch value { case 1: self = .pending; case 2: self = .completed; case 3: self = .rejected; case 4: self = .reversed; default: self = .unknown(value) } } }
enum TransactionType: Equatable {
    case deposit, withdrawal, incomingTransfer, outgoingTransfer, servicePayment, fee, adjustment, unknown(Int)
    init(_ value: Int) {
        switch value { case 1: self = .deposit; case 2: self = .withdrawal; case 3: self = .incomingTransfer; case 4: self = .outgoingTransfer; case 5: self = .servicePayment; case 6: self = .fee; case 7: self = .adjustment; default: self = .unknown(value) }
    }
}

