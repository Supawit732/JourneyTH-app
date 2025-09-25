import SwiftUI
import MapKit

enum LocationInputMode: String, CaseIterable, Identifiable {
    case poi
    case manual

    var id: String { rawValue }
}

struct LocationInputState {
    var mode: LocationInputMode = .poi
    var selectedPoiId: String?
    var latitudeText: String = ""
    var longitudeText: String = ""
}

@MainActor
final class FareEstimatorViewModel: ObservableObject {
    @Published var origin = LocationInputState()
    @Published var destination = LocationInputState()
    @Published private(set) var estimates: FareEstimates?
    @Published private(set) var distanceKm: Double?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var pois: [Poi] = []

    private let poiService: PoiServiceProtocol
    private let fareService: FareEstimatorServicing

    init(poiService: PoiServiceProtocol, fareService: FareEstimatorServicing) {
        self.poiService = poiService
        self.fareService = fareService
    }

    func load() async {
        do {
            pois = try await poiService.fetchPois().sorted { $0.nameEN < $1.nameEN }
            if origin.selectedPoiId == nil { origin.selectedPoiId = pois.first?.id }
            if destination.selectedPoiId == nil { destination.selectedPoiId = pois.dropFirst().first?.id ?? pois.first?.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func calculate(locale: Locale) async {
        isLoading = true
        errorMessage = nil
        do {
            guard let originCoordinate = coordinate(for: origin, locale: locale),
                  let destinationCoordinate = coordinate(for: destination, locale: locale) else {
                errorMessage = NSLocalizedString("transport.invalid.coords", comment: "")
                isLoading = false
                return
            }
            let distance = Self.haversine(originCoordinate, destinationCoordinate)
            distanceKm = distance
            estimates = try await fareService.estimateFares(for: distance)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func coordinate(for input: LocationInputState, locale: Locale) -> CLLocationCoordinate2D? {
        switch input.mode {
        case .poi:
            guard let id = input.selectedPoiId, let poi = pois.first(where: { $0.id == id }) else { return nil }
            return poi.coordinate
        case .manual:
            guard let lat = Double(input.latitudeText.replacingOccurrences(of: ",", with: ".")),
                  let lng = Double(input.longitudeText.replacingOccurrences(of: ",", with: ".")) else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
    }

    private static func haversine(_ origin: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D) -> Double {
        let radius = 6371.0
        let dLat = (destination.latitude - origin.latitude) * Double.pi / 180
        let dLon = (destination.longitude - origin.longitude) * Double.pi / 180
        let a = pow(sin(dLat / 2), 2) + cos(origin.latitude * Double.pi / 180) * cos(destination.latitude * Double.pi / 180) * pow(sin(dLon / 2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return radius * c
    }
}

struct TransportView: View {
    @ObservedObject var viewModel: FareEstimatorViewModel
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.locale) private var locale

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                inputSection(title: settings.localized("transport.origin"), state: $viewModel.origin)
                inputSection(title: settings.localized("transport.destination"), state: $viewModel.destination)

                Button {
                    Task { await viewModel.calculate(locale: locale) }
                } label: {
                    Label(settings.localized("transport.calculate"), systemImage: "function")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)

                if let distance = viewModel.distanceKm, let estimates = viewModel.estimates {
                    resultsSection(distance: distance, estimates: estimates)
                } else {
                    Text(settings.localized("transport.tip"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text(settings.localized("transport.disclaimer"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle(settings.localized("transport.title"))
        .task { await viewModel.load() }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessage {
                ErrorBanner(
                    message: error,
                    retryTitle: settings.localized("shared.try.again"),
                    onRetry: { Task { await viewModel.calculate(locale: locale) } }
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

    private func inputSection(title: String, state: Binding<LocationInputState>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            Picker(title, selection: state.mode) {
                ForEach(LocationInputMode.allCases) { mode in
                    Text(settings.localized(mode == .poi ? "transport.mode.poi" : "transport.mode.manual")).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            switch state.mode.wrappedValue {
            case .poi:
                Picker(settings.localized("transport.poi.placeholder"), selection: state.selectedPoiId) {
                    ForEach(viewModel.pois, id: \.id) { poi in
                        Text(poi.localizedName(locale: locale)).tag(Optional(poi.id))
                    }
                }
                .pickerStyle(.navigationLink)
            case .manual:
                VStack(alignment: .leading, spacing: 8) {
                    TextField(settings.localized("transport.lat"), text: state.latitudeText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    TextField(settings.localized("transport.lng"), text: state.longitudeText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)))
    }

    private func resultsSection(distance: Double, estimates: FareEstimates) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(format: settings.localized("transport.distance"), distance))
                .font(.title3.bold())
            VStack(spacing: 12) {
                fareRow(title: settings.localized("transport.taxi"), value: estimates.taxi)
                fareRow(title: settings.localized("transport.tuktuk"), value: estimates.tukTukMin, maxValue: estimates.tukTukMax)
                fareRow(title: settings.localized("transport.moto"), value: estimates.moto)
                if !estimates.motoNotes.isEmpty {
                    Text(settings.localized("transport.moto.notes") + ": " + estimates.motoNotes.map { settings.localized("transport.surcharge." + $0.reason) }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
            .shadow(radius: 2)
        }
    }

    private func fareRow(title: String, value: Double, maxValue: Double? = nil) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let maxValue, maxValue > value {
                let minText = currency(value)
                let maxText = currency(maxValue)
                Text(String(format: settings.localized("transport.range"), minText, maxText))
                    .font(.headline)
            } else {
                Text(currency(value))
                    .font(.headline)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(maxValue == nil ? "\(title) \(currency(value))" : "\(title) " + String(format: settings.localized("transport.range"), currency(value), currency(maxValue ?? value)))
    }

    private func currency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "THB"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value.rounded())) ?? "฿\(Int(value.rounded()))"
    }
}
