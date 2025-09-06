import Foundation

// MARK: - API Client Protocol
protocol APIClientProtocol {
    func request<T: Decodable>(
        path: String,
        method: String,
        body: Data?,
        queryItems: [URLQueryItem]?,
        retryingAfterRefresh: Bool
    ) async throws -> T
    
    func authenticate(username: String, password: String) async throws -> AuthToken
    func refreshToken() async throws -> AuthToken
}
