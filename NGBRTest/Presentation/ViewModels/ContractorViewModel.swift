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
    
    // MARK: - Private Properties
    private let contractorRepository: ContractorRepositoryProtocol
    private weak var appState: AppStateManager?
    
    // MARK: - Init
    init(contractorRepository: ContractorRepositoryProtocol, appState: AppStateManager? = nil) {
        self.contractorRepository = contractorRepository
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
            contractors = try await contractorRepository.fetchContractors()
        } catch APIError.unauthorized {
            errorMessage = "Необходима авторизация"
            await appState?.logout()
        } catch APIError.accessDenied {
            errorMessage = "Доступ запрещен"
        } catch {
            errorMessage = error.localizedDescription
            do {
                contractors = try await contractorRepository.loadContractorsFromLocal()
            } catch {
                contractors = []
                print("Ошибка при загрузке контрагента: \(error)")
            }
        }
        isLoading = false
    }
    
    func deleteContractor(_ contractor: Contractor) async {
        do {
            try await contractorRepository.deleteContractor(id: String(contractor.id))
            contractors.removeAll { $0.id == contractor.id }
        } catch APIError.unauthorized {
            await appState?.logout()
        } catch {
            errorMessage = "Ошибка при удалении: \(error.localizedDescription)"
            await loadContractors()
        }
    }
    
    func refreshContractors() async {
        await loadContractors()
    }
}
