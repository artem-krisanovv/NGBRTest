import Foundation
import SwiftUI

// MARK: - Contractor ViewModel
@MainActor
final class ContractorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var contractors: [Contractor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddContractor = false
    @Published var selectedContractor: Contractor?
    
    // MARK: - Dependencies
    private var appState: AppStateManager
    private let fetchContractorsUseCase: FetchContractorsUseCaseProtocol
    private let deleteContractorUseCase: DeleteContractorUseCaseProtocol
    private let loadLocalContractorsUseCase: LoadLocalContractorsUseCaseProtocol
    
    // MARK: - Initialization
    init(
        fetchContractorsUseCase: FetchContractorsUseCaseProtocol = FetchContractorsUseCase(),
        deleteContractorUseCase: DeleteContractorUseCaseProtocol = DeleteContractorUseCase(),
        loadLocalContractorsUseCase: LoadLocalContractorsUseCaseProtocol = LoadLocalContractorsUseCase(),
        appState: AppStateManager
    ) {
        self.fetchContractorsUseCase = fetchContractorsUseCase
        self.deleteContractorUseCase = deleteContractorUseCase
        self.loadLocalContractorsUseCase = loadLocalContractorsUseCase
        self.appState = appState
    }
    
    // MARK: - App State Update
    func updateAppState(_ appState: AppStateManager) {
        self.appState = appState
    }
    
    // MARK: - Data Operations
    func loadContractors() async {
        isLoading = true
        errorMessage = nil
        
        do {
            contractors = try await fetchContractorsUseCase.execute()
        } catch APIError.unauthorized {
            errorMessage = "Необходима авторизация"
            await appState.logout()
        } catch APIError.accessDenied {
            errorMessage = "Доступ запрещен"
        } catch {
            errorMessage = error.localizedDescription
            do {
                contractors = try await loadLocalContractorsUseCase.execute()
            } catch {
                contractors = []
                print("Ошибка при загрузке контрагента: \(error)")
            }
        }
        
        isLoading = false
    }
    
    func deleteContractor(_ contractor: Contractor) async {
        do {
            try await deleteContractorUseCase.execute(id: String(contractor.id))
            contractors.removeAll { $0.id == contractor.id }
        } catch APIError.unauthorized {
            await appState.logout()
        } catch {
            errorMessage = "Ошибка при удалении: \(error.localizedDescription)"
            await loadContractors()
        }
    }
    
    func refreshContractors() async {
        await loadContractors()
    }
}
