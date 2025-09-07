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
    
    // MARK: - Private Properties
    private let authRepository: AuthRepositoryProtocol
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - Init
    init(authRepository: AuthRepositoryProtocol, tokenManager: TokenManagerProtocol) {
        self.authRepository = authRepository
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
            _ = try await authRepository.login(username: username, password: password)
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
        await authRepository.logout()
        isAuthenticated = false
    }
    
    private func checkAuthenticationStatus() {
        if let _ = tokenManager.loadSavedToken() {
            isAuthenticated = true
        }
    }
}
