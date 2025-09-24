import SwiftUI
import MapKit

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.accentColor)
            .foregroundStyle(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.secondary.opacity(0.15))
            .clipShape(Capsule())
            .accessibilityLabel(Text(text))
    }
}

struct RatingRow: View {
    let rating: Double
    let localizedLabel: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(String(format: "%.1f", rating))
                .font(.subheadline.bold())
            Text(localizedLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(localizedLabel) \(rating)")
    }
}

struct PriceBadge: View {
    let price: String

    var body: some View {
        Text(price)
            .font(.caption.bold())
            .padding(6)
            .background(Color.green.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let imageSystemName: String
    let actionTitle: String?
    let action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: imageSystemName)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: {
                    Haptics.shared.play(.success)
                    action()
                })
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct RouteStepRow: View {
    let step: TransportStep

    var body: some View {
        HStack {
            Image(systemName: iconName(for: step.mode))
                .foregroundStyle(.accent)
            Text(step.name)
                .font(.body)
            Spacer()
            Text(step.mode)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.mode) - \(step.name)")
    }

    private func iconName(for mode: String) -> String {
        switch mode.lowercased() {
        case "train": return "train.side.front.car"
        case "bus": return "bus"
        case "ferry": return "ferry"
        case "walk": return "figure.walk"
        default: return "arrowshape.turn.up.right"
        }
    }
}

struct PoiCard: View {
    let poi: Poi
    let minutesLabel: String
    let ratingLabel: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            PoiSymbolBadge(imageKey: poi.images.first ?? poi.id)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(poi.name)
                        .font(.headline)
                    Spacer()
                    RatingRow(rating: poi.rating, localizedLabel: ratingLabel)
                }
                Text(poi.area)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(poi.minutes) \(minutesLabel)")
                    .font(.subheadline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(poi.tags, id: \.self) { tag in
                            TagChip(text: tag)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(poi.name), \(poi.area), \(poi.rating)")
    }
}

struct PoiSymbolBadge: View {
    let imageKey: String

    var body: some View {
        ZStack {
            Circle()
                .fill(PoiSymbolPalette.gradient(for: imageKey))
                .frame(width: 56, height: 56)
            Image(systemName: PoiSymbolPalette.symbol(for: imageKey))
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
        }
    }
}

struct PoiFilterBar: View {
    @Binding var selectedArea: String
    @Binding var selectedTags: Set<String>
    let areas: [String]
    let tags: [String]
    let resetTitle: String
    let onReset: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Menu {
                    Picker("Area", selection: $selectedArea) {
                        Text(resetTitle).tag("")
                        ForEach(areas, id: \.self) { area in
                            Text(area).tag(area)
                        }
                    }
                } label: {
                    Label(selectedArea.isEmpty ? resetTitle : selectedArea, systemImage: "mappin.and.ellipse")
                        .padding(8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }

                Menu {
                    ForEach(tags, id: \.self) { tag in
                        Button {
                            toggle(tag: tag)
                        } label: {
                            HStack {
                                Text(tag)
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Label(selectedTags.isEmpty ? resetTitle : selectedTags.joined(separator: ", "), systemImage: "line.3.horizontal.decrease.circle")
                        .padding(8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }

                Button(resetTitle) {
                    selectedArea = ""
                    selectedTags = []
                    onReset()
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
    }

    private func toggle(tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

struct PoiSymbolSlide: View {
    let imageKey: String
    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(PoiSymbolPalette.gradient(for: imageKey))
            Image(systemName: PoiSymbolPalette.symbol(for: imageKey))
                .font(.system(size: 96, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
        }
        .frame(height: 220)
        .padding(.horizontal)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
    }
}

enum PoiSymbolPalette {
    static func symbol(for key: String) -> String {
        switch key {
        case "wat_arun": return "sunrise.fill"
        case "chatuchak": return "cart.fill"
        case "chinatown": return "fork.knife.circle.fill"
        case "bua_tong": return "leaf.fill"
        case "doi_suthep": return "figure.hiking"
        case "nimman": return "sparkles"
        case "patong": return "sun.max.fill"
        case "phi_phi": return "water.waves"
        case "old_phuket": return "building.2.fill"
        case "asiatique": return "bag.fill"
        case "mae_kampong": return "leaf.circle.fill"
        case "karon": return "binoculars.fill"
        default: return "mappin.circle.fill"
        }
    }

    static func gradient(for key: String) -> LinearGradient {
        let colors: [Color]
        switch key {
        case "wat_arun":
            colors = [.orange, .pink]
        case "chatuchak":
            colors = [.green, .mint]
        case "chinatown":
            colors = [.red, .orange]
        case "bua_tong":
            colors = [.green, .teal]
        case "doi_suthep":
            colors = [.purple, .blue]
        case "nimman":
            colors = [.indigo, .pink]
        case "patong":
            colors = [.yellow, .orange]
        case "phi_phi":
            colors = [.teal, .blue]
        case "old_phuket":
            colors = [.blue, .purple]
        case "asiatique":
            colors = [.pink, .orange]
        case "mae_kampong":
            colors = [.green, .brown]
        case "karon":
            colors = [.cyan, .blue]
        default:
            colors = [.teal, .blue]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct QRPreviewView: View {
    let image: UIImage?
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .accessibilityLabel(Text(title))
            } else {
                ProgressView()
            }
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct MapRouteView: View {
    let coordinates: [CLLocationCoordinate2D]
    let title: String
    let originTitle: String
    let destinationTitle: String

    var body: some View {
        Map(initialPosition: .region(region)) {
            if coordinates.count > 1 {
                MapPolyline(coordinates)
                    .stroke(.blue, lineWidth: 4)
            }
            if let startCoordinate {
                Annotation(originTitle, coordinate: startCoordinate) {
                    annotationView(title: originTitle, color: .green)
                }
            }
            if let endCoordinate {
                Annotation(destinationTitle, coordinate: endCoordinate) {
                    annotationView(title: destinationTitle, color: .red)
                }
            }
        }
        .mapStyle(.standard)
        .overlay(alignment: .topLeading) {
            Text(title)
                .font(.headline)
                .padding(8)
                .background(.thinMaterial, in: Capsule())
                .padding()
        }
        .accessibilityLabel(Text(title))
    }

    private var region: MKCoordinateRegion {
        guard let first = coordinates.first else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        }
        var minLat = first.latitude
        var maxLat = first.latitude
        var minLon = first.longitude
        var maxLon = first.longitude
        for coordinate in coordinates.dropFirst() {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: max(0.01, maxLat - minLat + 0.02), longitudeDelta: max(0.01, maxLon - minLon + 0.02))
        return MKCoordinateRegion(center: center, span: span)
    }

    private var startCoordinate: CLLocationCoordinate2D? { coordinates.first }
    private var endCoordinate: CLLocationCoordinate2D? { coordinates.last }

    private func annotationView(title: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .padding(6)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

struct LoadingOverlay: View {
    let text: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(text)
                .font(.subheadline)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.thinMaterial))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

struct ErrorBanner: View {
    let message: String
    let retryTitle: String
    let onRetry: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.body)
            Spacer()
            Button(retryTitle, action: onRetry)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.1)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}
