import Foundation
import MapKit

struct StationsPayload: Codable {
    let stations: [RailStation]
    let lines: [RailLine]
}

struct RailStation: Identifiable, Codable, Equatable {
    let id: String
    let nameTH: String
    let nameEN: String
    let system: String
    let lat: Double
    let lng: Double
    let line: String

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

struct RailLine: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let system: String
    let stationIds: [String]
    let coordinates: [[Double]]

    var polyline: [CLLocationCoordinate2D] {
        coordinates.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
    }
}
