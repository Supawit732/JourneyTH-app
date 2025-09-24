import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "JourneyTH")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

struct ItineraryItemModel: Identifiable, Equatable {
    let id: UUID
    let poiId: String
    let order: Int
}

@MainActor
final class ItineraryRepository {
    private let context: NSManagedObjectContext
    private var itinerary: Itinerary

    init(context: NSManagedObjectContext) {
        self.context = context
        self.itinerary = ItineraryRepository.ensureItinerary(in: context)
    }

    private static func ensureItinerary(in context: NSManagedObjectContext) -> Itinerary {
        let request: NSFetchRequest<Itinerary> = Itinerary.fetchRequest()
        request.fetchLimit = 1
        if let existing = try? context.fetch(request).first {
            return existing
        }
        let itinerary = Itinerary(context: context)
        itinerary.id = UUID()
        itinerary.title = "Journey"
        itinerary.createdAt = Date()
        try? context.save()
        return itinerary
    }

    func items() throws -> [ItineraryItemModel] {
        let request: NSFetchRequest<ItineraryItem> = ItineraryItem.fetchRequest()
        request.predicate = NSPredicate(format: "itineraryId == %@", itinerary.id! as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        return try context.fetch(request).compactMap { item in
            guard let id = item.id, let poiId = item.poiId else { return nil }
            return ItineraryItemModel(id: id, poiId: poiId, order: Int(item.order))
        }
    }

    func add(poi: Poi) throws -> [ItineraryItemModel] {
        let item = ItineraryItem(context: context)
        item.id = UUID()
        item.poiId = poi.id
        item.itineraryId = itinerary.id
        let fetchRequest: NSFetchRequest<ItineraryItem> = ItineraryItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "itineraryId == %@", itinerary.id! as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
        fetchRequest.fetchLimit = 1
        let lastOrderValue = Int(try context.fetch(fetchRequest).first?.order ?? -1)
        item.order = Int16(lastOrderValue + 1)
        try context.save()
        return try items()
    }

    func remove(itemId: UUID) throws -> [ItineraryItemModel] {
        let request: NSFetchRequest<ItineraryItem> = ItineraryItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", itemId as CVarArg)
        let results = try context.fetch(request)
        for item in results {
            context.delete(item)
        }
        try context.save()
        return try normalizeOrders()
    }

    func reorder(from source: IndexSet, to destination: Int) throws -> [ItineraryItemModel] {
        var current = try items()
        current.move(fromOffsets: source, toOffset: destination)
        for (index, model) in current.enumerated() {
            let request: NSFetchRequest<ItineraryItem> = ItineraryItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
            if let item = try context.fetch(request).first {
                item.order = Int16(index)
            }
        }
        try context.save()
        return try items()
    }

    func clearAll() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = ItineraryItem.fetchRequest()
        let batch = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(batch)
        try context.save()
    }

    func totalMinutes(from pois: [Poi]) throws -> Int {
        let items = try self.items()
        let map = Dictionary(uniqueKeysWithValues: pois.map { ($0.id, $0) })
        return items.compactMap { map[$0.poiId]?.minutes }.reduce(0, +)
    }

    private func normalizeOrders() throws -> [ItineraryItemModel] {
        let current = try items().sorted { $0.order < $1.order }
        for (index, model) in current.enumerated() {
            let request: NSFetchRequest<ItineraryItem> = ItineraryItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
            if let item = try context.fetch(request).first {
                item.order = Int16(index)
            }
        }
        try context.save()
        return try items()
    }
}
