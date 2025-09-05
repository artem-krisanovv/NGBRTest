import Foundation
import SwiftUI

@MainActor
final class AppStateManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var showingLogin = false
    
    init() {
        checkAuthenticationStatus()
    }
    
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
