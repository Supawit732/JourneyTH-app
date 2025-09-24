import SwiftUI
import CoreImage.CIFilterBuiltins

@MainActor
final class EsimViewModel: ObservableObject {
    @Published private(set) var plans: [EsimPlan] = []
    @Published private(set) var latestOrder: OrderModel?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let planLoader: PlanLoading
    private let orderService: OrderServicing
    private let paymentProvider: PaymentProviding
    private let context = CIContext()

    init(planLoader: PlanLoading, orderService: OrderServicing, paymentProvider: PaymentProviding) {
        self.planLoader = planLoader
        self.orderService = orderService
        self.paymentProvider = paymentProvider
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            plans = try await planLoader.fetchPlans()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func refreshOrders(for plan: EsimPlan?) {
        do {
            if let plan {
                latestOrder = try orderService.latestOrder(for: plan)
            } else {
                latestOrder = try orderService.fetchOrders().first
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createOrder(for plan: EsimPlan) async {
        isLoading = true
        errorMessage = nil
        do {
            let order = try await orderService.createOrder(for: plan, provider: paymentProvider)
            latestOrder = order
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func markActivated() async {
        guard let order = latestOrder else { return }
        do {
            let status = await paymentProvider.markPaid(order: order)
            latestOrder = try orderService.markOrder(order.id, as: status)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func qrImage() -> UIImage? {
        guard let order = latestOrder else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        let payload = "plan=\(order.planId)&order=\(order.id.uuidString)"
        filter.setValue(Data(payload.utf8), forKey: "inputMessage")
        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        if let cgImage = context.createCGImage(scaled, from: scaled.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

struct EsimView: View {
    @ObservedObject var viewModel: EsimViewModel
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.plans.isEmpty {
                EmptyStateView(
                    title: settings.localized("esim.title"),
                    subtitle: settings.localized("esim.empty.subtitle"),
                    imageSystemName: "simcard.fill",
                    actionTitle: nil,
                    action: nil
                )
            } else {
                List(viewModel.plans) { plan in
                    NavigationLink(destination: EsimPlanDetailView(plan: plan, viewModel: viewModel)) {
                        EsimPlanRow(plan: plan)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle(settings.localized("esim.title"))
        .task {
            if viewModel.plans.isEmpty {
                await viewModel.load()
            }
        }
        .overlay(alignment: .top) {
            if let error = viewModel.errorMessage {
                ErrorBanner(
                    message: error,
                    retryTitle: settings.localized("shared.try.again"),
                    onRetry: { Task { await viewModel.load() } }
                )
                .padding()
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay(text: settings.localized("shared.loading"))
            }
        }
    }
}

struct EsimPlanRow: View {
    let plan: EsimPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(plan.name)
                    .font(.headline)
                Spacer()
                Text("฿\(plan.priceTHB)")
                    .font(.headline)
            }
            Text(plan.network)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(plan.validityDays) days • \(plan.speed)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct EsimPlanDetailView: View {
    let plan: EsimPlan
    @ObservedObject var viewModel: EsimViewModel
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.name)
                        .font(.largeTitle.bold())
                    Text(plan.network)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text(settings.localized("esim.plan.price") + ": ฿\(plan.priceTHB)")
                        .font(.headline)
                    Text("\(settings.localized("esim.plan.validity")) \(plan.validityDays) \(settings.localized("shared.days"))")
                        .font(.headline)
                    Text(settings.localized("esim.plan.speed"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(plan.speed)
                        .font(.body)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                if let order = viewModel.latestOrder {
                    OrderStatusView(order: order, qrImage: viewModel.qrImage(), onMarkActivated: {
                        Task { await viewModel.markActivated() }
                    })
                } else {
                    Button(settings.localized("esim.plan.purchase")) {
                        Task { await viewModel.createOrder(for: plan) }
                        Haptics.shared.play(.success)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding()
        }
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.refreshOrders(for: plan)
        }
    }
}
