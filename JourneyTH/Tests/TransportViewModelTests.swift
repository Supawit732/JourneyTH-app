import XCTest
@testable import JourneyTH

final class TransportViewModelTests: XCTestCase {
    func testRoutesDecodeFromJSON() throws {
        let loader = LocalDataLoader()
        let routes: [TransportRoute] = try loader.load("transport", as: [TransportRoute].self)
        XCTAssertGreaterThanOrEqual(routes.count, 6)
        XCTAssertEqual(routes.first?.steps.first?.mode, "Train")
    }

    func testSearchReturnsFilteredResults() async throws {
        let service = MockTransportService(loader: LocalDataLoader())
        let viewModel = await MainActor.run { TransportViewModel(service: service) }
        await MainActor.run {
            viewModel.origin = "Bangkok"
            viewModel.destination = "Siam"
            viewModel.search()
        }
        try await Task.sleep(nanoseconds: 200_000_000)
        let results = await MainActor.run { viewModel.routes }
        XCTAssertTrue(results.contains { $0.destination.contains("Siam") })
    }
}
