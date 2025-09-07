import SwiftUI

// MARK: - App State Manager
@MainActor
final class AppStateManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var showingLogin = false
    
    // MARK: - Private Properties
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - Init
    init(tokenManager: TokenManagerProtocol) {
        self.tokenManager = tokenManager
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Methods
    func checkAuthenticationStatus() {
        isAuthenticated = tokenManager.loadSavedToken() != nil
    }
    
    func logout() async {
        tokenManager.clearTokens()
        isAuthenticated = false
        showingLogin = true
    }
    
    func login() {
        isAuthenticated = true
        showingLogin = false
    }
}
