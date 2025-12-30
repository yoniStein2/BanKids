import Foundation

struct Transaction: Equatable, Identifiable, Codable, Hashable {
    let id: UUID
    var amount: Double
    var description: String
    var date: Date
    var type: TransactionType
    
    enum TransactionType: String, Codable, Equatable, Hashable {
        case income
        case outcome
    }
}
