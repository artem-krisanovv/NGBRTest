import SwiftUI

// MARK: - Contractor View Factory
struct ContractorViewFactory {
    @MainActor
    static func create(serviceContainer: ServiceContainer, appState: AppStateManager) -> ContractorView {
        let viewModel = ContractorViewModel(
            contractorRepository: serviceContainer.contractorRepository,
            appState: appState
        )
        return ContractorView(viewModel: viewModel)
    }
}
