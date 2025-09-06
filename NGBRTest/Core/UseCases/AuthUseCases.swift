import Foundation

// MARK: - Login Use Case Implementation
final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
    
    func execute(username: String, password: String) async throws -> AuthToken {
        return try await authRepository.login(username: username, password: password)
    }
}

// MARK: - Logout Use Case Implementation
final class LogoutUseCase: LogoutUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
    
    func execute() async {
        await authRepository.logout()
    }
}
