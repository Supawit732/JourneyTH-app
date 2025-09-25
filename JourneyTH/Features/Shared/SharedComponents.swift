import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.orange.opacity(0.15))
            .clipShape(Capsule())
            .accessibilityLabel(Text(text))
    }
}

struct RatingRow: View {
    let rating: Double
    let localizedLabel: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(String(format: "%.1f", rating))
                .font(.subheadline.bold())
            Text(localizedLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(localizedLabel) \(rating, specifier: "%.1f")")
    }
}

struct PoiCard: View {
    let poi: Poi
    let minutesLabel: String
    let ratingLabel: String
    let displayName: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            PoiSymbolBadge(imageKey: poi.image)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(displayName)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    RatingRow(rating: poi.rating, localizedLabel: ratingLabel)
                }
                Text(poi.area)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(poi.minutes) \(minutesLabel)")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(poi.tags, id: \.self) { TagChip(text: $0) }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(.secondarySystemBackground)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(displayName), \(poi.area), \(poi.minutes) \(minutesLabel)")
    }
}

struct PoiSymbolBadge: View {
    let imageKey: String

    var body: some View {
        ZStack {
            Circle()
                .fill(PoiSymbolPalette.gradient(for: imageKey))
                .frame(width: 64, height: 64)
            Image(systemName: PoiSymbolPalette.symbol(for: imageKey))
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(radius: 6)
        }
    }
}

enum PoiSymbolPalette {
    static func symbol(for key: String) -> String {
        switch key {
        case "wat_arun": return "sunrise.fill"
        case "chatuchak": return "cart.fill"
        case "chinatown": return "fork.knife.circle.fill"
        case "asiatique": return "bag.fill"
        case "bua_tong": return "leaf.fill"
        case "doi_suthep": return "figure.hiking"
        case "nimman": return "sparkles"
        case "mae_kampong": return "tree"
        case "patong": return "sun.max.fill"
        case "phi_phi": return "water.waves"
        case "old_phuket": return "building.columns"
        case "karon": return "binoculars.fill"
        default: return "mappin.circle.fill"
        }
    }

    static func gradient(for key: String) -> LinearGradient {
        let colors: [Color]
        switch key {
        case "wat_arun": colors = [.orange, .pink]
        case "chatuchak": colors = [.green, .mint]
        case "chinatown": colors = [.red, .orange]
        case "asiatique": colors = [.purple, .pink]
        case "bua_tong": colors = [.green, .teal]
        case "doi_suthep": colors = [.indigo, .purple]
        case "nimman": colors = [.pink, .orange]
        case "mae_kampong": colors = [.brown, .green]
        case "patong": colors = [.yellow, .orange]
        case "phi_phi": colors = [.teal, .blue]
        case "old_phuket": colors = [.cyan, .purple]
        case "karon": colors = [.blue, .teal]
        default: colors = [.orange, .pink]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct LoadingOverlay: View {
    let text: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .font(.subheadline)
                .lineLimit(2)
            Spacer()
            Button(retryTitle) {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
