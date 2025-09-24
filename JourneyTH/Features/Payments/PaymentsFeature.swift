import SwiftUI

struct OrderStatusView: View {
    let order: OrderModel
    let qrImage: UIImage?
    let onMarkActivated: () -> Void
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(settings.localized("esim.order.status"))
                    .font(.headline)
                Spacer()
                StatusBadge(status: order.status)
            }
            Text("฿\(order.amountTHB)")
                .font(.title2.bold())
            Text(settings.localized("esim.qr.instructions"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            QRPreviewView(
                image: qrImage,
                title: settings.localized(order.status.localizedKey),
                subtitle: settings.localized("esim.order.created") + " " + order.createdAt.formatted(date: .abbreviated, time: .shortened)
            )
            Button(settings.localized("esim.order.mark.activated")) {
                Haptics.shared.play(.success)
                onMarkActivated()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(order.status == .paid)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

struct StatusBadge: View {
    let status: OrderStatus
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Text(settings.localized(status.localizedKey))
            .font(.caption.bold())
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(backgroundColor.opacity(0.2))
            .foregroundStyle(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .pending: return .orange
        case .paid: return .green
        case .failed: return .red
        }
    }
}
