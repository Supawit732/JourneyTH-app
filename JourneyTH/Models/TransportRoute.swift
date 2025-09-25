import Foundation

struct FareConfigurationBundle: Codable {
    let fareConfig: FareConfig
    let railConfig: RailConfig
}

struct FareConfig: Codable {
    let taxi: [TaxiTier]
    let tuktuk: TukTukConfig
    let moto: MotoConfig
}

struct TaxiTier: Codable {
    let upToKm: Double?
    let rate: Double
}

struct TukTukConfig: Codable {
    let baseMin: Double
    let baseMax: Double
    let perKmMin: Double
    let perKmMax: Double
}

struct MotoConfig: Codable {
    let base2km: Double
    let perKm_2_5: Double
    let perKm_gt5: Double
    let surcharges: [FareSurcharge]
}

struct FareSurcharge: Codable {
    let reason: String
    let amount: Double
}

struct FareEstimates: Equatable {
    let taxi: Double
    let tukTukMin: Double
    let tukTukMax: Double
    let moto: Double
    let motoNotes: [FareSurcharge]
}

struct RailConfig: Codable {
    let urbanRail: [String: UrbanRailPricing]
    let intercityRail: IntercityRailPricing
}

struct UrbanRailPricing: Codable {
    let base: Double
    let perStop: [Double]
    let max: Double
}

struct IntercityRailPricing: Codable {
    let basePerKm: [String: Double]
    let classSurcharge: [String: Double]
    let nightSurcharge: Double
}
