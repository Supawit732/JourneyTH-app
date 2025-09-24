import Foundation

protocol PoiServiceProtocol {
    func fetchPois() async throws -> [Poi]
    func poi(with id: String) async throws -> Poi?
}

actor PoiStore {
    private var cached: [Poi]?

    func set(_ pois: [Poi]) { cached = pois }
    func all() -> [Poi]? { cached }
    func get(id: String) -> Poi? { cached?.first { $0.id == id } }
}

struct MockPoiService: PoiServiceProtocol {
    private let loader: DataLoading
    private let store = PoiStore()

    init(loader: DataLoading) {
        self.loader = loader
    }

    func fetchPois() async throws -> [Poi] {
        if let cached = await store.all() {
            return cached
        }
        let pois: [Poi] = try loader.load("pois", as: [Poi].self)
        await store.set(pois)
        return pois
    }

    func poi(with id: String) async throws -> Poi? {
        if let cached = await store.get(id: id) {
            return cached
        }
        let pois = try await fetchPois()
        return pois.first { $0.id == id }
    }
}
