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
        let testContractors = [
            Contractor(
                id: "1",
                name: "ООО Название компании",
                details: "Описание контрагента",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Contractor(
                id: "2",
                name: "ИП Иванов И.И.",
                details: "Описание ндивидуального предпринимателя",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Contractor(
                id: "3",
                name: "ООО Название компании",
                details: "Описание контрагента",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Contractor(
                id: "4",
                name: "ИП Петров И.И.",
                details: "Описание ндивидуального предпринимателя",
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        try await saveContractorsLocally(testContractors)
        
        return testContractors
    }
    
    func createContractor(_ contractor: CreateContractorRequest) async throws -> Contractor {
        let newContractor = Contractor(
            id: UUID().uuidString,
            name: contractor.name,
            details: contractor.details,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await saveContractorsLocally([newContractor])
        
        return newContractor
    }
    
    func updateContractor(id: String, _ contractor: UpdateContractorRequest) async throws -> Contractor {
        let updatedContractor = Contractor(
            id: id,
            name: contractor.name,
            details: contractor.details,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        try await saveContractorsLocally([updatedContractor])
        
        return updatedContractor
    }
    
    func deleteContractor(id: String) async throws {
        try await deleteContractorFromLocal(id: id)
    }
    
    func saveContractorsLocally(_ contractors: [Contractor]) async throws {
        let context = persistenceController.container.viewContext
        
        for contractor in contractors {
            let localContractor = contractor.toLocalModel()
            
            let fetchRequest: NSFetchRequest<Counterparty> = Counterparty.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", contractor.id)
            
            if let existing = try context.fetch(fetchRequest).first {
                existing.name = contractor.name
                existing.details = contractor.details
                existing.updatedAt = contractor.updatedAt
            } else {
                context.insert(localContractor)
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
