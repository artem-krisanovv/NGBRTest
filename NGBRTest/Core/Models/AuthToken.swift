import Foundation

// MARK: - Authentication Token Model
struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    
    // MARK: - Computed Properties
    var expiry: Date? {
        return JWTDecoder.decodeTokenInfo(from: accessToken)?.expirationDate
    }
    
    var roles: [String] {
        return JWTDecoder.decodeTokenInfo(from: accessToken)?.roles ?? []
    }
    
    var username: String? {
        return JWTDecoder.decodeTokenInfo(from: accessToken)?.username
    }
    
    var isValid: Bool {
        return JWTDecoder.decodeTokenInfo(from: accessToken)?.isValid ?? false
    }
    
    var isExpired: Bool {
        return JWTDecoder.decodeTokenInfo(from: accessToken)?.isExpired ?? true
    }
    
    // MARK: - Initialization
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    // MARK: - Update Method
    func updatedTokens(access: String, refresh: String) -> AuthToken {
        JWTDecoder.removeFromCache(accessToken)
        return AuthToken(accessToken: access, refreshToken: refresh)
    }
}
