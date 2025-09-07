import SwiftUI

// MARK: - Contractor Detail View Factory
struct ContractorDetailViewFactory {
    @MainActor
    static func create(contractor: Contractor? = nil, serviceContainer: ServiceContainer) -> ContractorDetailView {
        let viewModel = ContractorDetailViewModel(
            contractor: contractor,
            contractorRepository: serviceContainer.contractorRepository
        )
        return ContractorDetailView(viewModel: viewModel)
    }
}
