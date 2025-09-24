import Foundation

struct EsimPlan: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let network: String
    let priceTHB: Int
    let speed: String
    let validityDays: Int
}
