import SwiftUI

struct ItineraryDisplayItem: Identifiable, Equatable {
    let id: UUID
    let poi: Poi
    let order: Int
}

@MainActor
final class ItineraryViewModel: ObservableObject {
    @Published private(set) var items: [ItineraryDisplayItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: ItineraryRepository
    private let poiService: PoiServiceProtocol
    private let shareBuilder = ItineraryShareBuilder()
    private var cachedPois: [Poi] = []

    init(repository: ItineraryRepository, poiService: PoiServiceProtocol) {
        self.repository = repository
        self.poiService = poiService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            cachedPois = try await poiService.fetchPois()
            let stored = try repository.items()
            items = stored.compactMap { model in
                guard let poi = cachedPois.first(where: { $0.id == model.poiId }) else { return nil }
                return ItineraryDisplayItem(id: model.id, poi: poi, order: model.order)
            }.sorted { $0.order < $1.order }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func remove(_ item: ItineraryDisplayItem) {
        do {
            _ = try repository.remove(itemId: item.id)
            Task { await load() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        do {
            _ = try repository.reorder(from: source, to: destination)
            Task { await load() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func totalMinutes() -> Int {
        items.reduce(0) { $0 + $1.poi.minutes }
    }

    func shareText(using locale: Locale, minutesLabel: String) -> String {
        shareBuilder.makeShareText(title: "JourneyTH", pois: orderedPois(), locale: locale, minutesLabel: minutesLabel)
    }

    private func orderedPois() -> [Poi] {
        items.sorted { $0.order < $1.order }.map { $0.poi }
    }
}

struct ItineraryView: View {
    @ObservedObject var viewModel: ItineraryViewModel
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.items.isEmpty {
                ContentUnavailableView(
                    settings.localized("itinerary.empty.title"),
                    systemImage: "calendar",
                    description: Text(settings.localized("itinerary.empty.subtitle"))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: header) {
                        ForEach(viewModel.items) { item in
                            ItineraryRow(item: item)
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 8)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.remove(viewModel.items[index])
                            }
                        }
                        .onMove(perform: viewModel.move)
                    }
                }
                .listStyle(.insetGrouped)
                .toolbar { EditButton() }
            }
        }
        .padding()
        .navigationTitle(settings.localized("itinerary.title"))
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay(text: settings.localized("shared.loading"))
            }
        }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessage {
                ErrorBanner(
                    message: error,
                    retryTitle: settings.localized("shared.try.again"),
                    onRetry: { Task { await viewModel.load() } }
                )
                .padding()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: settings.localized("itinerary.total"), viewModel.totalMinutes(), settings.localized("shared.minutes.unit")))
                .font(.headline)
            ShareLink(item: viewModel.shareText(using: locale, minutesLabel: settings.localized("shared.minutes.unit"))) {
                Label(settings.localized("itinerary.share"), systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
        }
        .textCase(nil)
    }
}

private struct ItineraryRow: View {
    let item: ItineraryDisplayItem
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.poi.localizedName(locale: locale))
                .font(.headline)
            Text(item.poi.area)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(item.poi.minutes) \(settings.localized("shared.minutes.unit"))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.poi.localizedName(locale: locale)), \(item.poi.minutes) \(settings.localized("shared.minutes.unit"))")
    }
}
