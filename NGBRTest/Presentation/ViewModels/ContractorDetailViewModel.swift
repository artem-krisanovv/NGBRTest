import Foundation
import SwiftUI

@MainActor
final class ContractorDetailViewModel: ObservableObject {
    @Published var name = ""
    @Published var details = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    private let createContractorUseCase: CreateContractorUseCaseProtocol
    private let updateContractorUseCase: UpdateContractorUseCaseProtocol
    
    private let contractor: Contractor?
    private let isEditing: Bool
    
    init(contractor: Contractor? = nil,
         createContractorUseCase: CreateContractorUseCaseProtocol = CreateContractorUseCase(),
         updateContractorUseCase: UpdateContractorUseCaseProtocol = UpdateContractorUseCase()) {
        self.createContractorUseCase = createContractorUseCase
        self.updateContractorUseCase = updateContractorUseCase
        self.contractor = contractor
        self.isEditing = contractor != nil
        
        if let contractor = contractor {
            self.name = contractor.name
            self.details = contractor.fullName ?? ""
        }
    }
    
    func save() async {
        guard !name.isEmpty else {
            errorMessage = "Название контрагента обязательно"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isEditing {
                guard let contractor = contractor else { return }
                _ = try await updateContractorUseCase.execute(
                    id: String(contractor.id),
                    name: name,
                    details: details
                )
            } else {
                _ = try await createContractorUseCase.execute(
                    name: name,
                    details: details.isEmpty ? nil : details
                )
            }
            isSaved = true
        } catch APIError.unauthorized {
            errorMessage = "Необходима авторизация"
        } catch APIError.accessDenied {
            errorMessage = "Доступ запрещен"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    var title: String {
        isEditing ? "Редактировать контрагента" : "Новый контрагент"
    }
    
    var saveButtonTitle: String {
        isEditing ? "Сохранить" : "Создать"
    }
}
