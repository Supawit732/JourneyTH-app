import Foundation

protocol RailDataProviding {
    func stations() async throws -> [RailStation]
    func lines() async throws -> [RailLine]
}

actor RailDataStore {
    var payload: StationsPayload?
}

struct RailDataService: RailDataProviding {
    private let loader: DataLoading
    private let store = RailDataStore()

    init(loader: DataLoading) {
        self.loader = loader
    }

    func stations() async throws -> [RailStation] {
        try await ensurePayload().stations
    }

    func lines() async throws -> [RailLine] {
        try await ensurePayload().lines
    }

    private func ensurePayload() async throws -> StationsPayload {
        if let payload = await store.payload {
            return payload
        }
        let payload: StationsPayload = try loader.load("stations", as: StationsPayload.self)
        await store.payload = payload
        return payload
    }
}
