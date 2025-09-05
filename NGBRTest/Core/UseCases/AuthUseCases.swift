import Foundation

// MARK: - Auth Use Cases
protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) async throws -> AuthToken
}

protocol LogoutUseCaseProtocol {
    func execute() async
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
    
    func execute(username: String, password: String) async throws -> AuthToken {
        return try await authRepository.login(username: username, password: password)
    }
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
    
    func execute() async {
        await authRepository.logout()
    }
}
