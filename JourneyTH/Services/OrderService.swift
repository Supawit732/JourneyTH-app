import Foundation
import CoreData

protocol OrderServicing {
    @MainActor
    func createOrder(for plan: EsimPlan, provider: PaymentProviding) async throws -> OrderModel
    @MainActor
    func markOrder(_ id: UUID, as status: OrderStatus) throws -> OrderModel
    @MainActor
    func fetchOrders() throws -> [OrderModel]
    @MainActor
    func latestOrder(for plan: EsimPlan) throws -> OrderModel?
    @MainActor
    func clearOrders() throws
}

protocol PaymentProviding {
    func initiatePayment(amount: Int) async -> OrderStatus
    func markPaid(order: OrderModel) async -> OrderStatus
}

struct MockPaymentProvider: PaymentProviding {
    func initiatePayment(amount: Int) async -> OrderStatus {
        await Task.sleep(UInt64(0.2 * 1_000_000_000))
        return .pending
    }

    func markPaid(order: OrderModel) async -> OrderStatus {
        await Task.sleep(UInt64(0.1 * 1_000_000_000))
        return .paid
    }
}

@MainActor
final class OrderService: OrderServicing {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func createOrder(for plan: EsimPlan, provider: PaymentProviding) async throws -> OrderModel {
        let status = await provider.initiatePayment(amount: plan.priceTHB)
        let order = Order(context: context)
        order.id = UUID()
        order.amountTHB = Int32(plan.priceTHB)
        order.type = "esim"
        order.status = status.rawValue
        order.provider = "MockPay"
        order.createdAt = Date()
        order.planId = plan.id
        try context.save()
        return try makeModel(from: order)
    }

    func markOrder(_ id: UUID, as status: OrderStatus) throws -> OrderModel {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        guard let order = try context.fetch(fetchRequest).first else {
            throw NSError(domain: "OrderService", code: 1)
        }
        order.status = status.rawValue
        try context.save()
        return try makeModel(from: order)
    }

    func fetchOrders() throws -> [OrderModel] {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try context.fetch(request).map { try makeModel(from: $0) }
    }

    func latestOrder(for plan: EsimPlan) throws -> OrderModel? {
        let request: NSFetchRequest<Order> = Order.fetchRequest()
        request.predicate = NSPredicate(format: "planId == %@", plan.id)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 1
        return try context.fetch(request).first.flatMap { try? makeModel(from: $0) }
    }

    func clearOrders() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = Order.fetchRequest()
        let batch = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(batch)
        try context.save()
    }

    private func makeModel(from managedObject: Order) throws -> OrderModel {
        guard let id = managedObject.id,
              let type = managedObject.type,
              let statusRaw = managedObject.status,
              let status = OrderStatus(rawValue: statusRaw),
              let provider = managedObject.provider,
              let createdAt = managedObject.createdAt,
              let planId = managedObject.planId else {
            throw NSError(domain: "OrderService", code: 2)
        }
        return OrderModel(id: id, type: type, amountTHB: Int(managedObject.amountTHB), status: status, provider: provider, createdAt: createdAt, planId: planId)
    }
}
