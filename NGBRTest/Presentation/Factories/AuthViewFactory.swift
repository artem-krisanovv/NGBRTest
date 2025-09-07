import SwiftUI

// MARK: - Auth View Factory
struct AuthViewFactory {
    @MainActor
    static func create(serviceContainer: ServiceContainer, appState: AppStateManager) -> AuthView {
        let viewModel = AuthViewModel(
            authRepository: serviceContainer.authRepository,
            tokenManager: serviceContainer.tokenManager
        )
        return AuthView(viewModel: viewModel, appState: appState)
    }
}
