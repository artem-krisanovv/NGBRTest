import Foundation
import SwiftUI

// MARK: - Contractor Detail ViewModel
@MainActor
final class ContractorDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var details = ""
    @Published var inn = ""
    @Published var kpp = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSaved = false
    
    // MARK: - Dependencies
    private let createContractorUseCase: CreateContractorUseCaseProtocol
    private let updateContractorUseCase: UpdateContractorUseCaseProtocol
    
    private let contractor: Contractor?
    private let isEditing: Bool
    
    // MARK: - Initialization
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
            self.inn = contractor.inn
            self.kpp = contractor.kpp ?? ""
        }
    }
    
    // MARK: - Save Methods
    func save() async {
        guard !name.isEmpty else {
            errorMessage = "Название не может быть пустым"
            return
        }
        
        guard !inn.isEmpty else {
            errorMessage = "ИНН не может быть пустым"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if isEditing {
                _ = try await updateContractorUseCase.execute(
                    id: String(contractor!.id),
                    name: name,
                    details: details,
                    inn: inn,
                    kpp: kpp.isEmpty ? nil : kpp
                )
            } else {
                _ = try await createContractorUseCase.execute(
                    name: name,
                    details: details,
                    inn: inn,
                    kpp: kpp.isEmpty ? nil : kpp
                )
            }
            
            isSaved = true
            
        } catch ContractorError.success {
            isSaved = true
        } catch {
            errorMessage = "Ошибка при сохранении: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Title
    var title: String {
        isEditing ? "Редактировать" : "Новый контрагент"
    }
    
    var saveButtonTitle: String {
        isEditing ? "Сохранить" : "Создать"
    }
}
