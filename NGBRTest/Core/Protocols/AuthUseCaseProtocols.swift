import Foundation

// MARK: - Authentication Use Case Protocols
protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) async throws -> AuthToken
}

protocol LogoutUseCaseProtocol {
    func execute() async
}
