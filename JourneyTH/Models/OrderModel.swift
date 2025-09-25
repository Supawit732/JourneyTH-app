import Foundation

struct ItineraryShareBuilder {
    func makeShareText(title: String, pois: [Poi], locale: Locale, minutesLabel: String) -> String {
        var lines: [String] = []
        lines.append(title)
        lines.append(String(repeating: "=", count: max(3, title.count)))
        for (index, poi) in pois.enumerated() {
            let name = poi.localizedName(locale: locale)
            lines.append("\(index + 1). \(name) – \(poi.area)")
            lines.append("   • \(poi.minutes) \(minutesLabel)")
            if !poi.tags.isEmpty {
                lines.append("   • #\(poi.tags.joined(separator: " #"))")
            }
        }
        return lines.joined(separator: "\n")
    }
}
