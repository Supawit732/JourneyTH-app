import Foundation

protocol PlanLoading {
    func fetchPlans() async throws -> [EsimPlan]
}

struct LocalPlanLoader: PlanLoading {
    let loader: DataLoading

    init(loader: DataLoading) {
        self.loader = loader
    }

    func fetchPlans() async throws -> [EsimPlan] {
        try loader.load("esim_plans", as: [EsimPlan].self)
    }
}
