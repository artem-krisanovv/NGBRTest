import Foundation
import SwiftUI

@MainActor
final class ContractorViewModel: ObservableObject {
    @Published var contractors: [Contractor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddContractor = false
    @Published var selectedContractor: Contractor?
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func loadContractors() async {
        isLoading = true
        errorMessage = nil
        
        do {
            //
            contractors = []
        } catch APIError.unauthorized {
            errorMessage = "Необходима авторизация"
        } catch APIError.accessDenied {
            errorMessage = "Доступ запрещен"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteContractor(_ contractor: Contractor) async {
        do {
            // 
        } catch {
            errorMessage = "Ошибка при удалении: \(error.localizedDescription)"
        }
    }
    
    func refreshContractors() async {
        await loadContractors()
    }
}
