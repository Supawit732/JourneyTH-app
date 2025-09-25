import Foundation

protocol FareEstimatorServicing {
    func fareConfiguration() async throws -> FareConfig
    func railConfiguration() async throws -> RailConfig
    func estimateFares(for distanceKm: Double) async throws -> FareEstimates
}

actor FareConfigurationStore {
    var bundle: FareConfigurationBundle?
}

struct FareEstimatorService: FareEstimatorServicing {
    private let loader: DataLoading
    private let store = FareConfigurationStore()

    init(loader: DataLoading) {
        self.loader = loader
    }

    func fareConfiguration() async throws -> FareConfig {
        try await ensureBundle().fareConfig
    }

    func railConfiguration() async throws -> RailConfig {
        try await ensureBundle().railConfig
    }

    func estimateFares(for distanceKm: Double) async throws -> FareEstimates {
        let config = try await fareConfiguration()
        let distance = max(distanceKm, 0)
        let taxiFare = calculateTaxiFare(distance: distance, tiers: config.taxi)
        let tukTukMin = config.tuktuk.baseMin + distance * config.tuktuk.perKmMin
        let tukTukMax = config.tuktuk.baseMax + distance * config.tuktuk.perKmMax
        let motoFare = calculateMotoFare(distance: distance, config: config.moto)
        return FareEstimates(
            taxi: taxiFare,
            tukTukMin: tukTukMin,
            tukTukMax: tukTukMax,
            moto: motoFare,
            motoNotes: config.moto.surcharges
        )
    }

    private func ensureBundle() async throws -> FareConfigurationBundle {
        if let bundle = await store.bundle {
            return bundle
        }
        let bundle: FareConfigurationBundle = try loader.load("fares_config", as: FareConfigurationBundle.self)
        await store.bundle = bundle
        return bundle
    }

    private func calculateTaxiFare(distance: Double, tiers: [TaxiTier]) -> Double {
        guard let first = tiers.first else { return 0 }
        var total = first.rate
        var previousUpper = first.upToKm ?? 1
        if distance <= previousUpper { return total }

        for tier in tiers.dropFirst() {
            let upper = tier.upToKm ?? Double.greatestFiniteMagnitude
            let segment = max(min(distance, upper) - previousUpper, 0)
            if segment > 0 {
                total += segment * tier.rate
                previousUpper += segment
            }
            if distance <= upper { break }
            previousUpper = upper
        }
        return total
    }

    private func calculateMotoFare(distance: Double, config: MotoConfig) -> Double {
        if distance <= 0 { return config.base2km }
        if distance <= 2 {
            return config.base2km
        } else if distance <= 5 {
            return config.base2km + (distance - 2) * config.perKm_2_5
        } else {
            let midSegment = 3 * config.perKm_2_5
            return config.base2km + midSegment + (distance - 5) * config.perKm_gt5
        }
    }
}
