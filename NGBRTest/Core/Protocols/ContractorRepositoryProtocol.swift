import Foundation

// MARK: - Repository Protocol
protocol ContractorRepositoryProtocol {
    func fetchContractors() async throws -> [Contractor]
    func createContractor(_ contractor: CreateContractorRequest) async throws -> Contractor
    func updateContractor(id: String, _ contractor: UpdateContractorRequest) async throws -> Contractor
    func deleteContractor(id: String) async throws
    func saveContractorsLocally(_ contractors: [Contractor]) async throws
    func loadContractorsFromLocal() async throws -> [Contractor]
}
