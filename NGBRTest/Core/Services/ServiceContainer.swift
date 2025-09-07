import Foundation

// MARK: - Service Container
final class ServiceContainer: ObservableObject {
    // MARK: - Core Services
    let apiClient: APIClientProtocol
    let tokenManager: TokenManagerProtocol
    let keychainService: KeychainServiceProtocol
    
    // MARK: - Repositories
    let authRepository: AuthRepositoryProtocol
    let contractorRepository: ContractorRepositoryProtocol
    
    // MARK: - Init
    init() {
        self.keychainService = KeychainService()
        self.tokenManager = TokenManager(keychain: keychainService)

        self.apiClient = APIClient(
            baseURL: URL(string: "https://truck-api.ngbr.avesweb.ru/api")!,
            tokenManager: tokenManager
        )
        
        self.authRepository = AuthRepository(
            apiClient: apiClient,
            tokenManager: tokenManager
        )
        
        self.contractorRepository = ContractorRepository(
            apiClient: apiClient,
            persistenceController: PersistenceController.shared
        )
    }
}
