import Foundation

// MARK: - Repository Implementation
final class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let tokenManager: TokenManagerProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared,
         tokenManager: TokenManagerProtocol = TokenManager.shared) {
        self.apiClient = apiClient
        self.tokenManager = tokenManager
    }
    
    // MARK: - Authentication Methods
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
        clearCache()
    }
    
    // MARK: - Cache Management
    func clearCache() {
        JWTDecoder.clearCache()
    }
}
