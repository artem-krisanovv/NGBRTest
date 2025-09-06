import Foundation

// MARK: - Contractor Use Case Protocols
protocol FetchContractorsUseCaseProtocol {
    func execute() async throws -> [Contractor]
}

protocol CreateContractorUseCaseProtocol {
    func execute(name: String, details: String?, inn: String, kpp: String?) async throws -> Contractor
}

protocol UpdateContractorUseCaseProtocol {
    func execute(id: String, name: String, details: String?, inn: String, kpp: String?) async throws -> Contractor
}

protocol DeleteContractorUseCaseProtocol {
    func execute(id: String) async throws
}

protocol LoadLocalContractorsUseCaseProtocol {
    func execute() async throws -> [Contractor]
}
