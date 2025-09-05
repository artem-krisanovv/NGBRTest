import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let loginUseCase: LoginUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let tokenManager: TokenManagerProtocol
    
    init(
        loginUseCase: LoginUseCaseProtocol = LoginUseCase(),
        logoutUseCase: LogoutUseCaseProtocol = LogoutUseCase(),
        tokenManager: TokenManagerProtocol = TokenManager.shared
    ) {
        self.loginUseCase = loginUseCase
        self.logoutUseCase = logoutUseCase
        self.tokenManager = tokenManager
        
        checkAuthenticationStatus()
    }
    
    func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Пожалуйста, заполните все поля"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await loginUseCase.execute(username: username, password: password)
            isAuthenticated = true
            username = ""
            password = ""
        } catch APIError.unauthorized {
            errorMessage = "Неверный логин или пароль"
        } catch APIError.httpError(let status, let data) {
            var body = ""
            if let data = data, let s = String(data: data, encoding: .utf8) {
                body = s
            }
            errorMessage = "Ошибка сервера: \(status). \(body)"
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() async {
        await logoutUseCase.execute()
        isAuthenticated = false
    }
    
    func checkAuthenticationStatus() {
        if let _ = tokenManager.loadSavedToken() {
            isAuthenticated = true
        }
    }
}
