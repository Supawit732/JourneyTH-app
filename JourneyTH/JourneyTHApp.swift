import SwiftUI
import CoreData

@main
struct JourneyTHApp: App {
    @StateObject private var settings = AppSettings()
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(settings)
                .environmentObject(ServiceContainer.shared)
                .environment(\.locale, settings.locale)
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var container: ServiceContainer
    @State private var showSettings = false

    var body: some View {
        TabView {
            NavigationStack {
                DiscoverView(viewModel: DiscoverViewModel(service: container.poiService, itineraryRepository: container.itineraryRepository))
                    .toolbar { settingsButton }
            }
            .tabItem { Label(settings.localized("discover.title"), systemImage: "sparkles") }

            NavigationStack {
                ItineraryView(viewModel: ItineraryViewModel(repository: container.itineraryRepository, poiService: container.poiService))
                    .toolbar { settingsButton }
            }
            .tabItem { Label(settings.localized("itinerary.title"), systemImage: "list.bullet.rectangle") }

            NavigationStack {
                TransportView(viewModel: FareEstimatorViewModel(poiService: container.poiService, fareService: container.fareService))
                    .toolbar { settingsButton }
            }
            .tabItem { Label(settings.localized("transport.title"), systemImage: "car.fill") }

            NavigationStack {
                RailView(viewModel: RailViewModel(railService: container.railFareService))
                    .toolbar { settingsButton }
            }
            .tabItem { Label(settings.localized("rail.title"), systemImage: "tram.fill") }

            NavigationStack {
                AboutView()
                    .toolbar { settingsButton }
            }
            .tabItem { Label(settings.localized("about.title"), systemImage: "info.circle") }
        }
        .sheet(isPresented: $showSettings) {
            AccountView(viewModel: SettingsViewModel(settings: settings, itineraryRepository: container.itineraryRepository))
                .environmentObject(settings)
        }
    }

    private var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showSettings.toggle()
                Haptics.shared.play(.success)
            } label: {
                Image(systemName: "gearshape")
                    .accessibilityLabel(settings.localized("account.title"))
            }
        }
    }
}
