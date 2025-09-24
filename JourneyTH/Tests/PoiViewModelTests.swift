import XCTest
@testable import JourneyTH

final class PoiViewModelTests: XCTestCase {
    @MainActor
    private func makeViewModel() -> (PoiViewModel, ItineraryRepository) {
        let persistence = PersistenceController(inMemory: true)
        let repository = ItineraryRepository(context: persistence.container.viewContext)
        let viewModel = PoiViewModel(service: MockPoiService(loader: LocalDataLoader()), itineraryRepository: repository)
        return (viewModel, repository)
    }

    @MainActor
    func testLoadPoisUpdatesCollection() async throws {
        let (viewModel, _) = makeViewModel()
        await viewModel.load()
        XCTAssertGreaterThanOrEqual(viewModel.pois.count, 10)
        XCTAssertFalse(viewModel.filteredPois.isEmpty)
    }

    @MainActor
    func testAddToItineraryPersistsItem() async throws {
        let (viewModel, repository) = makeViewModel()
        await viewModel.load()
        guard let poi = viewModel.pois.first else {
            XCTFail("Missing poi")
            return
        }
        viewModel.addToItinerary(poi: poi)
        let items = try repository.items()
        XCTAssertEqual(items.count, 1)
    }

    func testLanguageTogglePersists() {
        let defaults = UserDefaults.standard
        defaults.set("en", forKey: "selectedLanguage")
        defer { defaults.set("en", forKey: "selectedLanguage") }
        let settings = AppSettings()
        XCTAssertFalse(settings.useThai)
        settings.useThai = true
        let stored = defaults.string(forKey: "selectedLanguage")
        XCTAssertEqual(stored, "th")
    }
}
