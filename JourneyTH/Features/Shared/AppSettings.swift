import Foundation
import SwiftUI
import Combine
import CoreData
import UIKit

final class AppSettings: ObservableObject {
    @AppStorage(Self.languageKey) private var storedLanguage: String = "en"

    @Published var locale: Locale
    @Published var useThai: Bool {
        didSet {
            let code = useThai ? "th" : "en"
            storedLanguage = code
            applyLanguage(code)
        }
    }

    private static let languageKey = "selectedLanguage"

    init() {
        let initialCode = Self.resolveLanguageCode(from: storedLanguage)
        storedLanguage = initialCode
        self.locale = Locale(identifier: initialCode)
        self.useThai = initialCode == "th"
    }

    func localized(_ key: String) -> String {
        LocalizationManager.shared.localizedString(forKey: key)
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func applyLanguage(_ code: String) {
        LocalizationManager.shared.setLanguage(code)
        locale = Locale(identifier: code)
    }

    private static func resolveLanguageCode(from stored: String) -> String {
        if stored == "th" || stored == "en" {
            return stored
        }
        return Locale.current.identifier.hasPrefix("th") ? "th" : "en"
    }
}

final class LocalizationManager {
    static let shared = LocalizationManager()
    private var bundle: Bundle = .main
    private var languageCode: String = Locale.current.identifier

    private init() {}

    func setLanguage(_ code: String) {
        languageCode = code
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
    }

    func localizedString(forKey key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    var locale: Locale {
        Locale(identifier: languageCode)
    }
}

final class ServiceContainer: ObservableObject {
    static let shared = ServiceContainer()

    let persistence: PersistenceController
    let transportService: TransportServiceProtocol
    let poiService: PoiServiceProtocol
    let orderService: OrderServicing
    let itineraryRepository: ItineraryRepository
    let planLoader: PlanLoading
    let paymentProvider: PaymentProviding

    private init() {
        let persistence = PersistenceController.shared
        self.persistence = persistence

        let dataLoader = LocalDataLoader()
        self.transportService = MockTransportService(loader: dataLoader)
        self.poiService = MockPoiService(loader: dataLoader)
        self.itineraryRepository = ItineraryRepository(context: persistence.container.viewContext)
        self.planLoader = LocalPlanLoader(loader: dataLoader)
        self.paymentProvider = MockPaymentProvider()
        self.orderService = OrderService(context: persistence.container.viewContext)
    }
}

final class Haptics {
    static let shared = Haptics()
    private init() {}

    func play(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
