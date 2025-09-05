import Foundation

// MARK: - Repository Protocol
protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> AuthToken
    func refreshToken() async throws -> AuthToken
    func logout() async
}

// MARK: - Repository Implementation
final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let tokenManager: TokenManagerProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared,
         tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }
    
    func login(username: String, password: String) async throws -> AuthToken {
        let response = try await apiClient.authenticate(username: username, password: password)
        return response
    }
    
    func refreshToken() async throws -> AuthToken {
        let response = try await apiClient.refreshToken()
        return response
    }
    
    func logout() async {
        tokenManager.clearTokens()
    }
}
