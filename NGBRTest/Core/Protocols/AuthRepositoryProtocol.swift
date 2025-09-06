import Foundation

// MARK: - Repository Protocol
protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> AuthToken
    func refreshToken() async throws -> AuthToken
    func logout() async
}
