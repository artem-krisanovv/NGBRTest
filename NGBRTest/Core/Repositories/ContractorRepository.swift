import Foundation
import CoreData

// MARK: - Repository Protocol
protocol ContractorRepositoryProtocol {
    func fetchContractors() async throws -> [Contractor]
    func createContractor(_ contractor: CreateContractorRequest) async throws -> Contractor
    func updateContractor(id: String, _ contractor: UpdateContractorRequest) async throws -> Contractor
    func deleteContractor(id: String) async throws
    func saveContractorsLocally(_ contractors: [Contractor]) async throws
    func loadContractorsFromLocal() async throws -> [Contractor]
}

// MARK: - Repository Implementation
final class ContractorRepository: ContractorRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let persistenceController: PersistenceController
    
    init(apiClient: APIClientProtocol = APIClient.shared,
         persistenceController: PersistenceController = .shared) {
        self.apiClient = apiClient
        self.persistenceController = persistenceController
    }
    
    func fetchContractors() async throws -> [Contractor] {
        do {
            let response: [Contractor] = try await apiClient.request(
                path: "/counterparty",
                method: "GET",
                body: nil,
                queryItems: nil,
                retryingAfterRefresh: false
            )
            
            try await saveContractorsLocally(response)
            
            return response
        } catch {
            print("API недоступен, загружаем из локально: \(error)")
            return try await loadContractorsFromLocal()
        }
    }
    func createContractor(_ contractor: CreateContractorRequest) async throws -> Contractor {
        let response: [String] = try await apiClient.request(
            path: "/counterparty/add",
            method: "POST",
            body: try JSONEncoder().encode(contractor),
            queryItems: nil,
            retryingAfterRefresh: false
        )
        
        print("API Response for create: \(response)")
        
        throw ContractorError.success
    }
    
    func updateContractor(id: String, _ contractor: UpdateContractorRequest) async throws -> Contractor {
        let response: [String: [String]] = try await apiClient.request(
            path: "/counterparty/edit",
            method: "POST",
            body: try JSONEncoder().encode(contractor),
            queryItems: nil,
            retryingAfterRefresh: false
        )
        
        print("API Response for update: \(response)")
        
        throw ContractorError.success
    }
    
    func deleteContractor(id: String) async throws {
        try await deleteContractorFromLocal(id: id)
    }
    
    func saveContractorsLocally(_ contractors: [Contractor]) async throws {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<Counterparty> = Counterparty.fetchRequest()
        let existingContractors = try context.fetch(fetchRequest)
        
        let newContractorIds = Set(contractors.map { String($0.id) })
        
        for existing in existingContractors {
            if let existingId = existing.id, !newContractorIds.contains(existingId) {
                context.delete(existing)
            }
        }
        
        for contractor in contractors {
            let contractorId = String(contractor.id)
            
            let existing = existingContractors.first { $0.id == contractorId }
            
            if let existing = existing {
                existing.name = contractor.name
                existing.details = contractor.fullName
                existing.inn = contractor.inn
                existing.kpp = contractor.kpp
                existing.updatedAt = Date()
            } else {
                let localContractor = Counterparty(context: context)
                localContractor.id = contractorId
                localContractor.name = contractor.name
                localContractor.details = contractor.fullName
                localContractor.inn = contractor.inn
                localContractor.kpp = contractor.kpp
                localContractor.updatedAt = Date()
            }
        }
        
        try context.save()
    }
    
    func loadContractorsFromLocal() async throws -> [Contractor] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Counterparty> = Counterparty.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Counterparty.name, ascending: true)]
        
        let localContractors = try context.fetch(fetchRequest)
        return localContractors.compactMap { Contractor.fromLocalModel($0) }
    }
    
    private func deleteContractorFromLocal(id: String) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Counterparty> = Counterparty.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        let contractors = try context.fetch(fetchRequest)
        contractors.forEach { context.delete($0) }
        
        try context.save()
    }
}
