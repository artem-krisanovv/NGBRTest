import Foundation

// MARK: - Token Manager Implementation
final class TokenManager: TokenManagerProtocol {
    // MARK: - Private Properties
    private let keychain: KeychainServiceProtocol
    private let accessKey = "com.ngbr.accessToken"
    private let refreshKey = "com.ngbr.refreshToken"
    private var refreshTask: Task<AuthToken, Error>?
    
    // MARK: - Init
    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }
    
    // MARK: - Token Storage
    func loadSavedToken() -> AuthToken? {
        guard let access = try? keychain.read(accessKey),
              let refresh = try? keychain.read(refreshKey) else {
            return nil
        }
        return AuthToken(accessToken: access, refreshToken: refresh)
    }
    
    func saveTokens(access: String, refresh: String) throws {
        try keychain.save(access, for: accessKey)
        try keychain.save(refresh, for: refreshKey)
        JWTDecoder.clearCache()
    }
    
    func clearTokens() {
        try? keychain.delete(accessKey)
        try? keychain.delete(refreshKey)
        JWTDecoder.clearCache()
    }
    
    // MARK: - Token Validation Func
    private func isAccessTokenValid(_ token: AuthToken) -> Bool {
        guard let exp = token.expiry else { return false }
        return exp.timeIntervalSinceNow > 60
    }
    
    func getValidAccessToken() async throws -> String {
        if let saved = loadSavedToken(), isAccessTokenValid(saved) {
            return saved.accessToken
        }
        let token = try await refreshToken()
        return token.accessToken
    }
    
    // MARK: - Token Refresh Func
    func refreshToken() async throws -> AuthToken {
        return try await refreshIfNeeded()
    }
    
    private func refreshIfNeeded() async throws -> AuthToken {
        if let existing = refreshTask {
            return try await existing.value
        }
        
        guard let saved = loadSavedToken() else {
            throw AuthError.noRefreshToken
        }
        
        let aKey = accessKey
        let rKey = refreshKey
        
        refreshTask = Task { [saved, aKey, rKey, keychain] in
            guard let url = URL(string: "https://truck-api.ngbr.avesweb.ru/api/token/refresh") else {
                throw AuthError.refreshFailed
            }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = ["refreshToken": saved.refreshToken]
            req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else { throw AuthError.refreshFailed }
            
            if http.statusCode == 401 {
                throw AuthError.unauthorized
            }
            guard (200..<300).contains(http.statusCode) else {
                throw AuthError.refreshFailed
            }
            
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let dict = json as? [String: Any],
                  let access = dict["accessToken"] as? String,
                  let refresh = dict["refreshToken"] as? String else {
                throw AuthError.refreshFailed
            }
            
            try keychain.save(access, for: aKey)
            try keychain.save(refresh, for: rKey)
            
            return AuthToken(accessToken: access, refreshToken: refresh)
        }
        
        defer { refreshTask = nil }
        
        do {
            let token = try await refreshTask!.value
            return token
        } catch {
            if let authErr = error as? AuthError, authErr == .unauthorized {
                clearTokens()
            }
            throw error
        }
    }
    
    // MARK: - Task Cancel
    func cancelRefreshTask() {
        refreshTask?.cancel()
        refreshTask = nil
    }
    
    // MARK: - Cache
    func clearTokenCache() {
        JWTDecoder.clearCache()
    }
    
    // MARK: - Deinit
    deinit {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
