import Foundation
import SwiftUI

// MARK: - App State Manager
@MainActor
final class AppStateManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var showingLogin = false
    
    // MARK: - Initialization
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Methods
    func checkAuthenticationStatus() {
        isAuthenticated = TokenManager.shared.loadSavedToken() != nil
    }
    
    func logout() async {
        TokenManager.shared.clearTokens()
        isAuthenticated = false
        showingLogin = true
    }
    
    func login() {
        isAuthenticated = true
        showingLogin = false
    }
}
