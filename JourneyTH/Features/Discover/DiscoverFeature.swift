import SwiftUI

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published private(set) var pois: [Poi] = [] {
        didSet { applyFilters() }
    }
    @Published var filteredPois: [Poi] = []
    @Published var selectedArea: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

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
            let results = try await service.fetchPois()
            self.pois = results
            self.isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func applyFilters() {
        guard !selectedArea.isEmpty else {
            filteredPois = pois
            return
        }
        filteredPois = pois.filter { $0.area == selectedArea }
    }

    var availableAreas: [String] {
        Array(Set(pois.map { $0.area })).sorted()
    }

    func addToItinerary(_ poi: Poi) {
        do {
            _ = try itineraryRepository.add(poi: poi)
            Haptics.shared.play(.success)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !viewModel.availableAreas.isEmpty {
                Picker(settings.localized("discover.filter.area"), selection: $viewModel.selectedArea) {
                    Text(settings.localized("discover.filter.all"))
                        .tag("")
                    ForEach(viewModel.availableAreas, id: \.self) { area in
                        Text(area).tag(area)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.selectedArea) { _ in viewModel.applyFilters() }
            }

            if viewModel.filteredPois.isEmpty {
                ContentUnavailableView(
                    settings.localized("discover.empty.title"),
                    systemImage: "map",
                    description: Text(settings.localized("discover.empty.subtitle"))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.filteredPois) { poi in
                    PoiRow(poi: poi) {
                        viewModel.addToItinerary(poi)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
                .listStyle(.plain)
                .refreshable { await viewModel.load() }
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

    @ViewBuilder
    private func PoiRow(poi: Poi, onAdd: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            PoiCard(
                poi: poi,
                minutesLabel: settings.localized("shared.minutes.unit"),
                ratingLabel: settings.localized("discover.rating"),
                displayName: poi.localizedName(locale: locale)
            )
            Button {
                onAdd()
            } label: {
                Label(settings.localized("discover.add"), systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityLabel(String(format: settings.localized("discover.add.accessibility"), poi.localizedName(locale: locale)))
        }
        .accessibilityElement(children: .contain)
    }
}
