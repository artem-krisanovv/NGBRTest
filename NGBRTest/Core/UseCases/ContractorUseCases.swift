import Foundation

// MARK: - Contractor Use Cases
protocol FetchContractorsUseCaseProtocol {
    func execute() async throws -> [Contractor]
}

protocol CreateContractorUseCaseProtocol {
    func execute(name: String, details: String?) async throws -> Contractor
}

protocol UpdateContractorUseCaseProtocol {
    func execute(id: String, name: String, details: String?) async throws -> Contractor
}

protocol DeleteContractorUseCaseProtocol {
    func execute(id: String) async throws
}

protocol LoadLocalContractorsUseCaseProtocol {
    func execute() async throws -> [Contractor]
}

final class FetchContractorsUseCase: FetchContractorsUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol = ContractorRepository()) {
        self.contractorRepository = contractorRepository
    }
    
    func execute() async throws -> [Contractor] {
        return try await contractorRepository.fetchContractors()
    }
}

final class CreateContractorUseCase: CreateContractorUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol = ContractorRepository()) {
        self.contractorRepository = contractorRepository
    }
    
    func execute(name: String, details: String?) async throws -> Contractor {
        let request = CreateContractorRequest(
            fullName: details,
            name: name,
            inn: "",
            kpp: nil
        )
        return try await contractorRepository.createContractor(request)
    }
}

final class UpdateContractorUseCase: UpdateContractorUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol = ContractorRepository()) {
        self.contractorRepository = contractorRepository
    }
    
    func execute(id: String, name: String, details: String?) async throws -> Contractor {
        guard let contractorId = Int(id) else {
            throw APIError.decodingError
        }
        
        let request = UpdateContractorRequest(
            id: contractorId,
            fullName: details,
            name: name,
            inn: "",
            kpp: nil
        )
        return try await contractorRepository.updateContractor(id: id, request)
    }
}

final class DeleteContractorUseCase: DeleteContractorUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol = ContractorRepository()) {
        self.contractorRepository = contractorRepository
    }
    
    func execute(id: String) async throws {
        try await contractorRepository.deleteContractor(id: id)
    }
}

final class LoadLocalContractorsUseCase: LoadLocalContractorsUseCaseProtocol {
    private let contractorRepository: ContractorRepositoryProtocol
    
    init(contractorRepository: ContractorRepositoryProtocol = ContractorRepository()) {
        self.contractorRepository = contractorRepository
    }
    
    func execute() async throws -> [Contractor] {
        return try await contractorRepository.loadContractorsFromLocal()
    }
}
