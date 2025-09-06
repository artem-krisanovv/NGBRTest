import Foundation

// MARK: - Token Manager Protocol
protocol TokenManagerProtocol {
    func loadSavedToken() -> AuthToken?
    func saveTokens(access: String, refresh: String) throws
    func clearTokens()
    func getValidAccessToken() async throws -> String
    func refreshToken() async throws -> AuthToken
}
