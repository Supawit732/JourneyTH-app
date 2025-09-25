import SwiftUI
import MapKit

@MainActor
final class RailViewModel: ObservableObject {
    @Published private(set) var stations: [RailStation] = []
    @Published private(set) var lines: [RailLine] = []
    @Published var fromStationId: String?
    @Published var toStationId: String?
    @Published private(set) var estimate: RailFareEstimate?
    @Published private(set) var isLoading = false
    @Published private(set) var isCalculating = false
    @Published var errorMessage: String?

    private let railService: RailFareServicing

    init(railService: RailFareServicing) {
        self.railService = railService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let loadedStations = try await railService.stations()
            stations = loadedStations
            lines = try await railService.lines()
            fromStationId = loadedStations.first?.id
            toStationId = loadedStations.dropFirst().first?.id ?? loadedStations.first?.id
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func estimateFare() async {
        guard let fromStation = selectedStation(id: fromStationId),
              let toStation = selectedStation(id: toStationId),
              fromStation.id != toStation.id else {
            errorMessage = NSLocalizedString("rail.invalid.selection", comment: "")
            return
        }
        isCalculating = true
        errorMessage = nil
        do {
            estimate = try await railService.estimate(from: fromStation, to: toStation)
            isCalculating = false
        } catch {
            errorMessage = error.localizedDescription
            isCalculating = false
        }
    }

    func selectedStation(id: String?) -> RailStation? {
        guard let id else { return nil }
        return stations.first { $0.id == id }
    }

    func highlightedLines() -> [RailLine] {
        guard let from = selectedStation(id: fromStationId) else { return lines }
        return lines.filter { $0.system == from.system }
    }

    func region() -> MKCoordinateRegion {
        if let from = selectedStation(id: fromStationId), let to = selectedStation(id: toStationId) {
            let minLat = min(from.lat, to.lat)
            let maxLat = max(from.lat, to.lat)
            let minLng = min(from.lng, to.lng)
            let maxLng = max(from.lng, to.lng)
            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2)
            let span = MKCoordinateSpan(latitudeDelta: max(0.1, maxLat - minLat + 0.15), longitudeDelta: max(0.1, maxLng - minLng + 0.15))
            return MKCoordinateRegion(center: center, span: span)
        }
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    }
}

struct RailView: View {
    @ObservedObject var viewModel: RailViewModel
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.locale) private var locale
    @State private var mapPosition: MapCameraPosition

    init(viewModel: RailViewModel) {
        self.viewModel = viewModel
        _mapPosition = State(initialValue: .region(viewModel.region()))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                railMap
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                pickerSection

                Button {
                    Task { await viewModel.estimateFare() }
                } label: {
                    Label(settings.localized("rail.calculate"), systemImage: "tram.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isCalculating)

                if let estimate = viewModel.estimate,
                   let from = viewModel.selectedStation(id: viewModel.fromStationId),
                   let to = viewModel.selectedStation(id: viewModel.toStationId) {
                    summarySection(estimate: estimate, from: from, to: to)
                } else {
                    Text(settings.localized("rail.tip"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text(settings.localized("rail.disclaimer"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(settings.localized("rail.title"))
        .task { await viewModel.load() }
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
            if viewModel.isLoading || viewModel.isCalculating {
                LoadingOverlay(text: settings.localized("shared.loading"))
            }
        }
    }

    private var railMap: some View {
        Map(position: $mapPosition) {
            ForEach(viewModel.highlightedLines()) { line in
                MapPolyline(line.polyline)
                    .stroke(color(for: line.system), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            }
            ForEach(viewModel.stations) { station in
                Annotation(station.localizedName(locale: locale), coordinate: station.coordinate) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(color(for: station.system))
                            .frame(width: 12, height: 12)
                        Text(station.localizedName(locale: locale))
                            .font(.caption2)
                            .padding(4)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
            }
        }
        .mapStyle(.standard)
        .accessibilityLabel(settings.localized("rail.map"))
        .onChange(of: viewModel.fromStationId) { _ in
            mapPosition = .region(viewModel.region())
        }
        .onChange(of: viewModel.toStationId) { _ in
            mapPosition = .region(viewModel.region())
        }
    }

    private var pickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            stationPicker(title: settings.localized("rail.from"), selection: $viewModel.fromStationId)
            stationPicker(title: settings.localized("rail.to"), selection: $viewModel.toStationId)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)))
    }

    private func stationPicker(title: String, selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Picker(title, selection: selection) {
                ForEach(viewModel.stations, id: \.id) { station in
                    Text(station.localizedName(locale: locale)).tag(Optional(station.id))
                }
            }
            .pickerStyle(.navigationLink)
        }
    }

    private func summarySection(estimate: RailFareEstimate, from: RailStation, to: RailStation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(format: settings.localized("rail.summary"), from.localizedName(locale: locale), to.localizedName(locale: locale), estimate.distanceKm))
                .font(.title3.bold())
            if estimate.isUrban {
                Text(settings.localized("rail.urban." + estimate.system.lowercased()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(settings.localized("rail.intercity"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(currency(estimate.price))
                .font(.system(size: 34, weight: .bold))
            Button(settings.localized("rail.open.maps")) {
                openInMaps(from: from, to: to)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .shadow(radius: 3)
    }

    private func color(for system: String) -> Color {
        switch system {
        case "BTS": return .green
        case "MRT": return .blue
        case "ARL": return .orange
        case "SRT": return .red
        default: return .gray
        }
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "THB"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value.rounded())) ?? "฿\(Int(value.rounded()))"
    }

    private func openInMaps(from: RailStation, to: RailStation) {
        let origin = MKMapItem(placemark: MKPlacemark(coordinate: from.coordinate, addressDictionary: nil))
        origin.name = from.localizedName(locale: locale)
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: to.coordinate, addressDictionary: nil))
        destination.name = to.localizedName(locale: locale)
        MKMapItem.openMaps(with: [origin, destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeTransit])
    }
}
