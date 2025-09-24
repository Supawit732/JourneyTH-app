import XCTest
@testable import JourneyTH

@MainActor
final class ItineraryRepositoryTests: XCTestCase {
    private var repository: ItineraryRepository!

    override func setUp() async throws {
        let persistence = PersistenceController(inMemory: true)
        repository = ItineraryRepository(context: persistence.container.viewContext)
    }

    func testAddAndFetchItems() throws {
        let poi = Poi(id: "test", name: "Test", area: "Bangkok", rating: 4.0, tags: ["Food"], minutes: 60, latitude: 0, longitude: 0, images: [])
        let items = try repository.add(poi: poi)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.poiId, "test")
    }

    func testReorderChangesOrder() throws {
        let first = Poi(id: "first", name: "First", area: "Bangkok", rating: 4.2, tags: [], minutes: 30, latitude: 0, longitude: 0, images: [])
        let second = Poi(id: "second", name: "Second", area: "Bangkok", rating: 4.1, tags: [], minutes: 40, latitude: 0, longitude: 0, images: [])
        _ = try repository.add(poi: first)
        _ = try repository.add(poi: second)
        let updated = try repository.reorder(from: IndexSet(integer: 0), to: 2)
        XCTAssertEqual(updated.first?.poiId, "second")
    }

    func testTotalMinutesMatchesSum() throws {
        let poiA = Poi(id: "a", name: "A", area: "Bangkok", rating: 4.0, tags: [], minutes: 30, latitude: 0, longitude: 0, images: [])
        let poiB = Poi(id: "b", name: "B", area: "Bangkok", rating: 4.0, tags: [], minutes: 45, latitude: 0, longitude: 0, images: [])
        _ = try repository.add(poi: poiA)
        _ = try repository.add(poi: poiB)
        let total = try repository.totalMinutes(from: [poiA, poiB])
        XCTAssertEqual(total, 75)
    }
}
