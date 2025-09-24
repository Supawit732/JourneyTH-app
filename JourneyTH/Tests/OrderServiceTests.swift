import XCTest
@testable import JourneyTH

@MainActor
final class OrderServiceTests: XCTestCase {
    private var service: OrderService!
    private var provider: MockPaymentProvider!

    override func setUp() async throws {
        let persistence = PersistenceController(inMemory: true)
        service = OrderService(context: persistence.container.viewContext)
        provider = MockPaymentProvider()
    }

    func testCreateOrderIsPending() async throws {
        let plan = EsimPlan(id: "test", name: "Test", network: "Mock", priceTHB: 100, speed: "Fast", validityDays: 3)
        let order = try await service.createOrder(for: plan, provider: provider)
        XCTAssertEqual(order.status, .pending)
        XCTAssertEqual(order.amountTHB, 100)
    }

    func testMarkActivatedTransitionsToPaid() async throws {
        let plan = EsimPlan(id: "test", name: "Test", network: "Mock", priceTHB: 100, speed: "Fast", validityDays: 3)
        let order = try await service.createOrder(for: plan, provider: provider)
        let updated = try service.markOrder(order.id, as: .paid)
        XCTAssertEqual(updated.status, .paid)
    }

    func testFetchOrdersReturnsLatest() async throws {
        let plan = EsimPlan(id: "plan1", name: "Plan", network: "Mock", priceTHB: 120, speed: "Fast", validityDays: 5)
        _ = try await service.createOrder(for: plan, provider: provider)
        let orders = try service.fetchOrders()
        XCTAssertEqual(orders.count, 1)
        XCTAssertEqual(orders.first?.planId, "plan1")
    }
}
