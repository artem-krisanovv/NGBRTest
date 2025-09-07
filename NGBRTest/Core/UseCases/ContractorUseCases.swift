import Foundation

// MARK: - Fetch Use Case Implementation
final class FetchContractorsUseCase: FetchContractorsUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol) {
        self.contractorRepository = contractorRepository
    }
    
    func execute() async throws -> [Contractor] {
        return try await contractorRepository.fetchContractors()
    }
}

// MARK: - Create Use Case Implementation
final class CreateContractorUseCase: CreateContractorUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol) {
        self.contractorRepository = contractorRepository
    }
    
    func execute(name: String, details: String?, inn: String, kpp: String?) async throws -> Contractor {
        let request = CreateContractorRequest(
            fullName: details,
            name: name,
            inn: inn,
            kpp: kpp
        )
        return try await contractorRepository.createContractor(request)
    }
}

// MARK: - Update Use Case Implementation
final class UpdateContractorUseCase: UpdateContractorUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol) {
        self.contractorRepository = contractorRepository
    }
    
    func execute(id: String, name: String, details: String?, inn: String, kpp: String?) async throws -> Contractor {
        guard let contractorId = Int(id) else {
            throw APIError.decodingError
        }
        
        let request = UpdateContractorRequest(
            id: contractorId,
            fullName: details,
            name: name,
            inn: inn,
            kpp: kpp
        )
        return try await contractorRepository.updateContractor(id: id, request)
    }
}

// MARK: - Delete Use Case Implementation
final class DeleteContractorUseCase: DeleteContractorUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol) {
        self.contractorRepository = contractorRepository
    }
    
    func execute(id: String) async throws {
        try await contractorRepository.deleteContractor(id: id)
    }
}

// MARK: - Local Use Case Implementation
final class LoadLocalContractorsUseCase: LoadLocalContractorsUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol) {
        self.contractorRepository = contractorRepository
    }
    
    func execute() async throws -> [Contractor] {
        return try await contractorRepository.loadContractorsFromLocal()
    }
}
