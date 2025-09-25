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
        let poi = Poi(id: "test", nameTH: "ทดสอบ", nameEN: "Test", area: "Bangkok", rating: 4.0, tags: ["Food"], minutes: 60, lat: 0, lng: 0, image: "wat_arun")
        let items = try repository.add(poi: poi)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.poiId, "test")
    }

    func testReorderChangesOrder() throws {
        let first = Poi(id: "first", nameTH: "หนึ่ง", nameEN: "First", area: "Bangkok", rating: 4.2, tags: [], minutes: 30, lat: 0, lng: 0, image: "wat_arun")
        let second = Poi(id: "second", nameTH: "สอง", nameEN: "Second", area: "Bangkok", rating: 4.1, tags: [], minutes: 40, lat: 0, lng: 0, image: "wat_arun")
        _ = try repository.add(poi: first)
        _ = try repository.add(poi: second)
        let updated = try repository.reorder(from: IndexSet(integer: 0), to: 2)
        XCTAssertEqual(updated.first?.poiId, "second")
    }

    func testTotalMinutesMatchesSum() throws {
        let poiA = Poi(id: "a", nameTH: "เอ", nameEN: "A", area: "Bangkok", rating: 4.0, tags: [], minutes: 30, lat: 0, lng: 0, image: "wat_arun")
        let poiB = Poi(id: "b", nameTH: "บี", nameEN: "B", area: "Bangkok", rating: 4.0, tags: [], minutes: 45, lat: 0, lng: 0, image: "wat_arun")
        _ = try repository.add(poi: poiA)
        _ = try repository.add(poi: poiB)
        let total = try repository.totalMinutes(from: [poiA, poiB])
        XCTAssertEqual(total, 75)
    }
}
