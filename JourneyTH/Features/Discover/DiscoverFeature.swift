import SwiftUI
import MapKit

@MainActor
final class PoiViewModel: ObservableObject {
    @Published private(set) var pois: [Poi] = []
    @Published private(set) var filteredPois: [Poi] = []
    @Published var selectedArea: String = ""
    @Published var selectedTags: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let areas = ["Bangkok", "Chiang Mai", "Phuket"]
    let tags = ["Temple", "Food", "Market", "Night"]

    private let service: PoiServiceProtocol
    private let itineraryRepository: ItineraryRepository

    init(service: PoiServiceProtocol, itineraryRepository: ItineraryRepository) {
        self.service = service
        self.itineraryRepository = itineraryRepository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await service.fetchPois()
            pois = data
            applyFilters()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func applyFilters() {
        filteredPois = pois.filter { poi in
            let matchesArea = selectedArea.isEmpty || poi.area == selectedArea
            let matchesTags = selectedTags.isEmpty || !Set(poi.tags).isDisjoint(with: selectedTags)
            return matchesArea && matchesTags
        }
    }

    func addToItinerary(poi: Poi) {
        do {
            _ = try itineraryRepository.add(poi: poi)
            Haptics.shared.play(.success)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearFilters() {
        selectedArea = ""
        selectedTags = []
        applyFilters()
    }
}

struct DiscoverView: View {
    @ObservedObject var viewModel: PoiViewModel
    @EnvironmentObject private var settings: AppSettings
    @State private var displayMode: DisplayMode = .list

    enum DisplayMode: String, CaseIterable, Identifiable {
        case list
        case map

        var id: String { rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker(settings.localized("discover.toggle.title"), selection: $displayMode) {
                Text(settings.localized("discover.toggle.list")).tag(DisplayMode.list)
                Text(settings.localized("discover.toggle.map")).tag(DisplayMode.map)
            }
            .pickerStyle(.segmented)

            PoiFilterBar(
                selectedArea: $viewModel.selectedArea,
                selectedTags: $viewModel.selectedTags,
                areas: viewModel.areas,
                tags: viewModel.tags,
                resetTitle: settings.localized("discover.filter.reset"),
                onReset: viewModel.clearFilters
            )
            .onChange(of: viewModel.selectedArea) { _ in viewModel.applyFilters() }
            .onChange(of: viewModel.selectedTags) { _ in viewModel.applyFilters() }

            Group {
                switch displayMode {
                case .list:
                    if viewModel.filteredPois.isEmpty {
                        EmptyStateView(
                            title: settings.localized("discover.empty.title"),
                            subtitle: settings.localized("discover.empty.subtitle"),
                            imageSystemName: "safari",
                            actionTitle: nil,
                            action: nil
                        )
                    } else {
                        List(viewModel.filteredPois) { poi in
                            NavigationLink(destination: PoiDetailView(poi: poi, onAdd: { viewModel.addToItinerary(poi: poi) })) {
                                PoiCard(
                                    poi: poi,
                                    minutesLabel: settings.localized("shared.minutes.unit"),
                                    ratingLabel: settings.localized("discover.rating.label")
                                )
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.load()
                        }
                    }
                case .map:
                    Map(initialPosition: .automatic) {
                        ForEach(viewModel.filteredPois) { poi in
                            Annotation(poi.name, coordinate: poi.coordinate) {
                                VStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.red)
                                    Text(poi.name)
                                        .font(.caption)
                                        .fixedSize()
                                }
                                .padding(4)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .mapStyle(.standard)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .accessibilityLabel(settings.localized("discover.map.accessibility"))
                }
            }
        }
        .padding()
        .navigationTitle(settings.localized("discover.title"))
        .task {
            if viewModel.pois.isEmpty {
                await viewModel.load()
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
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay(text: settings.localized("shared.loading"))
            }
        }
    }
}

struct PoiDetailView: View {
    let poi: Poi
    let onAdd: () -> Void
    @EnvironmentObject private var settings: AppSettings

    private var slideKeys: [String] {
        poi.images.isEmpty ? [poi.id] : poi.images
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TabView {
                    ForEach(slideKeys, id: \.self) { imageKey in
                        PoiSymbolSlide(imageKey: imageKey, title: poi.name)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 240)

                VStack(alignment: .leading, spacing: 12) {
                    Text(poi.name)
                        .font(.title.bold())
                    Text(poi.area)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    RatingRow(rating: poi.rating, localizedLabel: settings.localized("discover.rating.label"))
                    Text("\(poi.minutes) \(settings.localized("shared.minutes.unit"))")
                        .font(.headline)
                    HStack {
                        ForEach(poi.tags, id: \.self) { TagChip(text: $0) }
                    }
                    Button(settings.localized("add.to.itinerary")) {
                        Haptics.shared.play(.success)
                        onAdd()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            }
            .padding()
        }
        .navigationTitle(poi.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
