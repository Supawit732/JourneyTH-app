import XCTest
@testable import JourneyTH

final class OrderServiceTests: XCTestCase {
    func testUrbanEstimateUsesStops() async throws {
        let loader = LocalDataLoader()
        let fareService = FareEstimatorService(loader: loader)
        let dataService = RailDataService(loader: loader)
        let railService = RailFareService(dataService: dataService, fareService: fareService)
        let stations = try await railService.stations()
        guard let from = stations.first(where: { $0.id == "bts_mo_chit" }),
              let to = stations.first(where: { $0.id == "bts_asok" }) else {
            XCTFail("Missing stations")
            return
        }
        let estimate = try await railService.estimate(from: from, to: to)
        XCTAssertTrue(estimate.isUrban)
        XCTAssertGreaterThan(estimate.stops, 0)
        XCTAssertGreaterThan(estimate.price, 0)
    }

    func testIntercityEstimateUsesDistance() async throws {
        let loader = LocalDataLoader()
        let fareService = FareEstimatorService(loader: loader)
        let dataService = RailDataService(loader: loader)
        let railService = RailFareService(dataService: dataService, fareService: fareService)
        let stations = try await railService.stations()
        guard let from = stations.first(where: { $0.id == "srt_hua_lamphong" }),
              let to = stations.first(where: { $0.id == "srt_ayutthaya" }) else {
            XCTFail("Missing stations")
            return
        }
        let estimate = try await railService.estimate(from: from, to: to)
        XCTAssertFalse(estimate.isUrban)
        XCTAssertGreaterThan(estimate.distanceKm, 50)
        XCTAssertGreaterThan(estimate.price, 0)
    }
}
