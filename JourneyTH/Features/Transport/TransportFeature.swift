import SwiftUI
import MapKit

@MainActor
final class TransportViewModel: ObservableObject {
    @Published var origin: String = "Bangkok"
    @Published var destination: String = "Siam"
    @Published var travelDate: Date = .now
    @Published private(set) var routes: [TransportRoute] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var searchTask: Task<Void, Never>?
    private let service: TransportServiceProtocol

    init(service: TransportServiceProtocol) {
        self.service = service
    }

    func loadInitial() {
        search()
    }

    func search() {
        searchTask?.cancel()
        isLoading = true
        errorMessage = nil
        let origin = origin
        let destination = destination
        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await service.searchRoutes(from: origin, to: destination)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.routes = results
                    self.isLoading = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

struct TransportView: View {
    @ObservedObject var viewModel: TransportViewModel
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            searchForm
            if viewModel.routes.isEmpty {
                EmptyStateView(
                    title: settings.localized("transport.title"),
                    subtitle: settings.localized("transport.search.empty"),
                    imageSystemName: "tram.fill",
                    actionTitle: settings.localized("transport.search.button"),
                    action: viewModel.search
                )
            } else {
                List(viewModel.routes) { route in
                    NavigationLink(destination: TransportDetailView(route: route, travelDate: viewModel.travelDate)) {
                        TransportRouteRow(route: route)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.insetGrouped)
            }
        }
        .padding()
        .navigationTitle(settings.localized("transport.title"))
        .task {
            if viewModel.routes.isEmpty {
                viewModel.loadInitial()
            }
        }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessage {
                ErrorBanner(
                    message: error,
                    retryTitle: settings.localized("shared.try.again"),
                    onRetry: viewModel.search
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

    private var searchForm: some View {
        VStack(spacing: 12) {
            TextField(settings.localized("transport.origin.placeholder"), text: $viewModel.origin)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
            TextField(settings.localized("transport.destination.placeholder"), text: $viewModel.destination)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
            DatePicker(settings.localized("transport.travel.date"), selection: $viewModel.travelDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
            Button(settings.localized("transport.search.button")) {
                Haptics.shared.play(.success)
                viewModel.search()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct TransportRouteRow: View {
    let route: TransportRoute
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(route.origin) → \(route.destination)")
                        .font(.headline)
                    Text("\(settings.localized("transport.duration")) \(route.formattedDuration)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                PriceBadge(price: route.formattedPrice)
            }
            HStack {
                ForEach(route.steps) { step in
                    TagChip(text: step.mode)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(route.origin) to \(route.destination) \(route.formattedDuration) \(route.formattedPrice)")
    }
}

struct TransportDetailView: View {
    let route: TransportRoute
    let travelDate: Date
    @EnvironmentObject private var settings: AppSettings
    @State private var showFullMap = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !route.coordinates.isEmpty {
                    MapRouteView(
                        coordinates: route.coordinates,
                        title: "\(route.origin) → \(route.destination)",
                        originTitle: route.origin,
                        destinationTitle: route.destination
                    )
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.top)
                    Button {
                        Haptics.shared.play(.success)
                        showFullMap = true
                    } label: {
                        Label(settings.localized("transport.view.map"), systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                travelInfo
                VStack(alignment: .leading, spacing: 12) {
                    Text(settings.localized("transport.steps.title"))
                        .font(.title3.bold())
                    ForEach(route.steps) { step in
                        RouteStepRow(step: step)
                        Divider()
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            }
            .padding()
        }
        .navigationTitle("\(route.origin) → \(route.destination)")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFullMap) {
            NavigationStack {
                MapRouteView(
                    coordinates: route.coordinates,
                    title: "\(route.origin) → \(route.destination)",
                    originTitle: route.origin,
                    destinationTitle: route.destination
                )
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(settings.localized("transport.view.map"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(settings.localized("shared.close")) {
                            showFullMap = false
                        }
                    }
                }
            }
        }
    }
}

private extension TransportDetailView {
    var travelInfo: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundStyle(.accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(settings.localized("transport.travel.date"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(travelDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(settings.localized("transport.travel.date")) \(travelDate.formatted(date: .abbreviated, time: .shortened))")
    }
}
