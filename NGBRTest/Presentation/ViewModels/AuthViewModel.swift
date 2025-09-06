import Foundation
import SwiftUI

// MARK: - Auth ViewModel
@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    // MARK: - Dependencies
    private let loginUseCase: LoginUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - Initialization
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
    
    // MARK: - Authentication Methods
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
        } catch APIError.accessDenied {
            errorMessage = "Доступ запрещен"
        } catch APIError.httpError {
            errorMessage = "Ошибка сервера"
        } catch {
            errorMessage = "Произошла ошибка при авторизации"
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
