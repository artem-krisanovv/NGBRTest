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
    
    // MARK: - Private Properties
    private let contractorRepository: ContractorRepositoryProtocol
    private let contractor: Contractor?
    
    // MARK: - Computed Properties
    var title: String {
        contractor == nil ? "Добавить контрагента" : "Редактировать"
    }
    
    var saveButtonTitle: String {
        contractor == nil ? "Создать" : "Сохранить"
    }
    
    // MARK: - Init
    init(contractor: Contractor? = nil, contractorRepository: ContractorRepositoryProtocol) {
        self.contractor = contractor
        self.contractorRepository = contractorRepository
        
        if let contractor = contractor {
            self.name = contractor.name
            self.details = contractor.fullName ?? ""
            self.inn = contractor.inn
            self.kpp = contractor.kpp ?? ""
        }
    }
    
    // MARK: - Save Method
    func save() async {
        guard !name.isEmpty else {
            errorMessage = "Название не может быть пустым"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if let contractor = contractor {
                _ = try await contractorRepository.updateContractor(
                    id: String(contractor.id),
                    UpdateContractorRequest(
                        id: Int(contractor.id),
                        fullName: details.isEmpty ? nil : details,
                        name: name,
                        inn: inn,
                        kpp: kpp.isEmpty ? nil : kpp
                    )
                )
            } else {
                _ = try await contractorRepository.createContractor(
                    CreateContractorRequest(
                        fullName: details.isEmpty ? nil : details,
                        name: name,
                        inn: inn,
                        kpp: kpp.isEmpty ? nil : kpp
                    )
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
}

