import Foundation

protocol TransportServiceProtocol {
    func fetchRoutes() async throws -> [TransportRoute]
    func searchRoutes(from origin: String, to destination: String) async throws -> [TransportRoute]
}

actor TransportRouteStore {
    private var cachedRoutes: [TransportRoute]?

    func cached() -> [TransportRoute]? { cachedRoutes }
    func set(_ routes: [TransportRoute]) { cachedRoutes = routes }
}

struct MockTransportService: TransportServiceProtocol {
    private let loader: DataLoading
    private let store = TransportRouteStore()

    init(loader: DataLoading) {
        self.loader = loader
    }

    func fetchRoutes() async throws -> [TransportRoute] {
        if let cached = await store.cached() {
            return cached
        }
        let routes: [TransportRoute] = try loader.load("transport", as: [TransportRoute].self)
        await store.set(routes)
        return routes
    }

    func searchRoutes(from origin: String, to destination: String) async throws -> [TransportRoute] {
        let routes = try await fetchRoutes()
        let trimmedOrigin = origin.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedDestination = destination.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmedOrigin.isEmpty || !trimmedDestination.isEmpty else {
            return routes
        }

        return routes.filter { route in
            let originMatch = trimmedOrigin.isEmpty || route.origin.lowercased().contains(trimmedOrigin)
            let destinationMatch = trimmedDestination.isEmpty || route.destination.lowercased().contains(trimmedDestination)
            return originMatch && destinationMatch
        }
    }
}
