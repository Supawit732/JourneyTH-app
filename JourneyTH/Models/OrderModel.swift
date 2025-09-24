import Foundation

enum OrderStatus: String, CaseIterable, Codable {
    case pending
    case paid
    case failed

    var localizedKey: String {
        switch self {
        case .pending: return "esim.order.pending"
        case .paid: return "esim.order.paid"
        case .failed: return "esim.order.failed"
        }
    }
}

struct OrderModel: Identifiable, Equatable {
    let id: UUID
    let type: String
    let amountTHB: Int
    var status: OrderStatus
    let provider: String
    let createdAt: Date
    let planId: String
}
