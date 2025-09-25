import XCTest
@testable import JourneyTH

final class TransportViewModelTests: XCTestCase {
    func testFareConfigurationLoads() async throws {
        let service = FareEstimatorService(loader: LocalDataLoader())
        let config = try await service.fareConfiguration()
        XCTAssertFalse(config.taxi.isEmpty)
        XCTAssertGreaterThan(config.moto.base2km, 0)
    }

    func testEstimateProducesValues() async throws {
        let service = FareEstimatorService(loader: LocalDataLoader())
        let estimates = try await service.estimateFares(for: 12.5)
        XCTAssertGreaterThan(estimates.taxi, 0)
        XCTAssertGreaterThan(estimates.tukTukMax, estimates.tukTukMin)
        XCTAssertGreaterThan(estimates.moto, 0)
    }
}
