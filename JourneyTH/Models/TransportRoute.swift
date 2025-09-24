import Foundation
import MapKit

struct TransportRoute: Identifiable, Codable, Equatable {
    let id: String
    let origin: String
    let destination: String
    let durationMinutes: Int
    let priceTHB: Double
    let steps: [TransportStep]
    let polyline: [RouteCoordinate]?

    var formattedDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var formattedPrice: String {
        String(format: "฿%.0f", priceTHB)
    }

    var coordinates: [CLLocationCoordinate2D] {
        (polyline ?? []).map { $0.location }
    }
}

struct TransportStep: Identifiable, Codable, Equatable {
    var id: String { name + mode }
    let mode: String
    let name: String
}

struct RouteCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double

    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
