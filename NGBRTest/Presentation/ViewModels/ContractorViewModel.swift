import Foundation
import SwiftUI

@MainActor
final class ContractorViewModel: ObservableObject {
    @Published var contractors: [Contractor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddContractor = false
    @Published var selectedContractor: Contractor?
    
    private let fetchContractorsUseCase: FetchContractorsUseCaseProtocol
    private let deleteContractorUseCase: DeleteContractorUseCaseProtocol
    private let loadLocalContractorsUseCase: LoadLocalContractorsUseCaseProtocol
    
    init(
        fetchContractorsUseCase: FetchContractorsUseCaseProtocol = FetchContractorsUseCase(),
        deleteContractorUseCase: DeleteContractorUseCaseProtocol = DeleteContractorUseCase(),
        loadLocalContractorsUseCase: LoadLocalContractorsUseCaseProtocol = LoadLocalContractorsUseCase()
    ) {
        self.fetchContractorsUseCase = fetchContractorsUseCase
        self.deleteContractorUseCase = deleteContractorUseCase
        self.loadLocalContractorsUseCase = loadLocalContractorsUseCase
    }
    
    func loadContractors() async {
        isLoading = true
        errorMessage = nil
        
        do {
            contractors = try await fetchContractorsUseCase.execute()
        } catch APIError.unauthorized {
            errorMessage = "Необходима авторизация"
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
            await loadContractors()
        } catch {
            errorMessage = "Ошибка при удалении: \(error.localizedDescription)"
        }
    }
    
    func refreshContractors() async {
        await loadContractors()
    }
}
