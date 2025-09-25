import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                JourneyTHLogo()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                Text(settings.localized("about.tagline"))
                    .font(.title3)
                    .foregroundStyle(.secondary)

                section(title: settings.localized("about.methodology")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(settings.localized("about.methodology.fares"))
                        Text(settings.localized("about.methodology.rail"))
                        Text(settings.localized("about.methodology.itinerary"))
                    }
                }

                section(title: settings.localized("about.data")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(settings.localized("about.data.pois"), systemImage: "map")
                        Label(settings.localized("about.data.fares"), systemImage: "creditcard")
                        Label(settings.localized("about.data.stations"), systemImage: "tram.fill")
                    }
                }

                section(title: settings.localized("about.credits")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(settings.localized("about.credits.text"))
                        Text(settings.localized("about.disclaimer"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(settings.localized("about.title"))
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)))
    }
}

struct JourneyTHLogo: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [.orange, .pink, .yellow], startPoint: .leading, endPoint: .trailing))
                .frame(width: 120, height: 120)
                .overlay {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(radius: 6)
                }
                .accessibilityHidden(true)
            Text("JourneyTH")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                .accessibilityLabel("JourneyTH")
        }
    }
}
