import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var useThai: Bool
    @Published var message: String?

    private let settings: AppSettings
    private let orderService: OrderServicing
    private let itineraryRepository: ItineraryRepository

    init(settings: AppSettings, orderService: OrderServicing, itineraryRepository: ItineraryRepository) {
        self.settings = settings
        self.orderService = orderService
        self.itineraryRepository = itineraryRepository
        self.useThai = settings.useThai
    }

    func toggleLanguage(_ value: Bool) {
        settings.useThai = value
        useThai = value
    }

    func clearData() {
        do {
            try itineraryRepository.clearAll()
            try orderService.clearOrders()
            message = settings.localized("account.cleared")
        } catch {
            message = error.localizedDescription
        }
    }

    var versionText: String {
        settings.localized("account.version") + ": " + settings.appVersion
    }
}

struct AccountView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Form {
            Section(header: Text(settings.localized("account.profile.section"))) {
                HStack {
                    Image(systemName: "person.crop.square")
                        .font(.largeTitle)
                        .foregroundStyle(.accent)
                    VStack(alignment: .leading) {
                        Text("JourneyTH Explorer")
                            .font(.headline)
                        Text(settings.localized("account.local.profile"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Toggle(settings.localized("account.language.toggle"), isOn: Binding(
                    get: { viewModel.useThai },
                    set: { newValue in viewModel.toggleLanguage(newValue) }
                ))
                Text(viewModel.versionText)
                    .font(.footnote)
            }

            Section(header: Text(settings.localized("account.settings.section"))) {
                Button(role: .destructive) {
                    Haptics.shared.play(.success)
                    viewModel.clearData()
                } label: {
                    Text(settings.localized("account.clear.data"))
                }
            }
            if let message = viewModel.message {
                Section {
                    Text(message)
                }
            }
        }
        .navigationTitle(settings.localized("account.title"))
    }
}
