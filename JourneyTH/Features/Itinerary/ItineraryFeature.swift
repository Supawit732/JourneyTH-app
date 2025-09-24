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
    @Published var shareText: String = ""

    private let repository: ItineraryRepository
    private let poiService: PoiServiceProtocol
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
            }.sorted(by: { $0.order < $1.order })
            shareText = makeShareText()
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

    func clear() {
        do {
            try repository.clearAll()
            Task { await load() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func totalMinutes() -> Int {
        items.reduce(0) { $0 + $1.poi.minutes }
    }

    private func makeShareText() -> String {
        items.sorted(by: { $0.order < $1.order }).enumerated().map { index, item in
            "Day \(index + 1): \(item.poi.name) - \(item.poi.minutes) minutes"
        }.joined(separator: "\n")
    }
}

struct ItineraryView: View {
    @ObservedObject var viewModel: ItineraryViewModel
    @EnvironmentObject private var settings: AppSettings
    @State private var showShare = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.items.isEmpty {
                EmptyStateView(
                    title: settings.localized("itinerary.empty.title"),
                    subtitle: settings.localized("itinerary.empty.subtitle"),
                    imageSystemName: "calendar",
                    actionTitle: settings.localized("itinerary.cta.discover"),
                    action: nil
                )
            } else {
                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.poi.name)
                                    .font(.headline)
                                Text("\(item.poi.minutes) \(settings.localized("shared.minutes.unit"))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(item.poi.area)
                                    .font(.caption)
                            }
                            Spacer()
                            Button(role: .destructive) {
                                viewModel.remove(item)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .accessibilityLabel(settings.localized("itinerary.remove.accessibility"))
                        }
                    }
                    .onMove(perform: viewModel.move)
                }
                .listStyle(.insetGrouped)
                .toolbar { EditButton() }

                HStack {
                    Text("\(settings.localized("itinerary.total.minutes")) \(viewModel.totalMinutes())")
                        .font(.headline)
                    Spacer()
                    ShareLink(item: viewModel.shareText) {
                        Label(settings.localized("itinerary.share"), systemImage: "square.and.arrow.up")
                    }
                }
                Button(role: .destructive) {
                    viewModel.clear()
                } label: {
                    Text(settings.localized("account.clear.data"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .navigationTitle(settings.localized("itinerary.title"))
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
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
}
