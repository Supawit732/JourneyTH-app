import SwiftUI
import CoreData
import MapKit

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
    @State private var showAccount = false

    var body: some View {
        TabView {
            NavigationStack {
                TransportView(viewModel: TransportViewModel(service: container.transportService))
                    .toolbar {
                        accountButton
                    }
            }
            .tabItem {
                Label(settings.localized("transport.title"), systemImage: "tram.fill")
            }

            NavigationStack {
                DiscoverView(viewModel: PoiViewModel(service: container.poiService, itineraryRepository: container.itineraryRepository))
                    .toolbar {
                        accountButton
                    }
            }
            .tabItem {
                Label(settings.localized("discover.title"), systemImage: "map")
            }

            NavigationStack {
                ItineraryView(viewModel: ItineraryViewModel(repository: container.itineraryRepository, poiService: container.poiService))
                    .toolbar {
                        accountButton
                    }
            }
            .tabItem {
                Label(settings.localized("itinerary.title"), systemImage: "list.bullet.rectangle")
            }

            NavigationStack {
                EsimView(viewModel: EsimViewModel(planLoader: container.planLoader, orderService: container.orderService, paymentProvider: container.paymentProvider))
                    .toolbar {
                        accountButton
                    }
            }
            .tabItem {
                Label(settings.localized("esim.title"), systemImage: "simcard")
            }
        }
        .sheet(isPresented: $showAccount) {
            NavigationStack {
                AccountView(viewModel: SettingsViewModel(settings: settings, orderService: container.orderService, itineraryRepository: container.itineraryRepository))
            }
        }
    }

    private var accountButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAccount.toggle()
                Haptics.shared.play(.success)
            } label: {
                Image(systemName: "person.crop.circle")
                    .accessibilityLabel(settings.localized("account.title"))
            }
        }
    }
}
