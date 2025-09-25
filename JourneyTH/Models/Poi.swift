import Foundation
import MapKit

struct Poi: Identifiable, Codable, Equatable {
    let id: String
    let nameTH: String
    let nameEN: String
    let area: String
    let rating: Double
    let tags: [String]
    let minutes: Int
    let lat: Double
    let lng: Double
    let image: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    func localizedName(locale: Locale) -> String {
        if locale.identifier.hasPrefix("th") {
            return nameTH
        }
        return nameEN
    }
}
