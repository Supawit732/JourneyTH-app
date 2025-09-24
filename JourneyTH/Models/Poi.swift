import Foundation
import MapKit

struct Poi: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let area: String
    let rating: Double
    let tags: [String]
    let minutes: Int
    let latitude: Double
    let longitude: Double
    let images: [String]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
