import Foundation

struct RailFareEstimate: Equatable {
    let system: String
    let distanceKm: Double
    let stops: Int
    let price: Double
    let isUrban: Bool
}

protocol RailFareServicing {
    func estimate(from: RailStation, to: RailStation) async throws -> RailFareEstimate
    func lines() async throws -> [RailLine]
    func stations() async throws -> [RailStation]
}

struct RailFareService: RailFareServicing {
    private let dataService: RailDataProviding
    private let fareService: FareEstimatorServicing

    init(dataService: RailDataProviding, fareService: FareEstimatorServicing) {
        self.dataService = dataService
        self.fareService = fareService
    }

    func stations() async throws -> [RailStation] {
        try await dataService.stations()
    }

    func lines() async throws -> [RailLine] {
        try await dataService.lines()
    }

    func estimate(from: RailStation, to: RailStation) async throws -> RailFareEstimate {
        let distance = distanceBetween(from, to)
        let railConfig = try await fareService.railConfiguration()
        if from.system == to.system, from.system != "SRT" {
            let stops = try await stopCount(from: from, to: to)
            let price = urbanPrice(for: from.system, stops: stops, config: railConfig.urbanRail)
            return RailFareEstimate(system: from.system, distanceKm: distance, stops: stops, price: price, isUrban: true)
        } else {
            let price = intercityPrice(distance: distance, config: railConfig.intercityRail)
            return RailFareEstimate(system: "SRT", distanceKm: distance, stops: 0, price: price, isUrban: false)
        }
    }

    private func distanceBetween(_ origin: RailStation, _ destination: RailStation) -> Double {
        let earthRadius = 6371.0
        let dLat = (destination.lat - origin.lat) * Double.pi / 180
        let dLon = (destination.lng - origin.lng) * Double.pi / 180
        let a = pow(sin(dLat / 2), 2) + cos(origin.lat * Double.pi / 180) * cos(destination.lat * Double.pi / 180) * pow(sin(dLon / 2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }

    private func stopCount(from: RailStation, to: RailStation) async throws -> Int {
        let lines = try await dataService.lines()
        for line in lines where line.system == from.system {
            if let startIndex = line.stationIds.firstIndex(of: from.id),
               let endIndex = line.stationIds.firstIndex(of: to.id) {
                return abs(endIndex - startIndex)
            }
        }
        return 0
    }

    private func urbanPrice(for system: String, stops: Int, config: [String: UrbanRailPricing]) -> Double {
        guard let pricing = config[system] else { return 0 }
        var total = pricing.base
        if stops <= 0 {
            return min(total, pricing.max)
        }
        for i in 0..<stops {
            let increment = i < pricing.perStop.count ? pricing.perStop[i] : pricing.perStop.last ?? 0
            total += increment
            if total >= pricing.max { return pricing.max }
        }
        return min(total, pricing.max)
    }

    private func intercityPrice(distance: Double, config: IntercityRailPricing) -> Double {
        let baseRate = config.basePerKm["express"] ?? config.basePerKm.values.first ?? 0
        var price = distance * baseRate
        price += config.classSurcharge["second"] ?? 0
        if distance > 150 {
            price += config.nightSurcharge
        }
        return max(price, 20)
    }
}
