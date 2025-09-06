import Foundation

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let username: String
    let password: String
}

// MARK: - Response Models
struct LoginResponse: Codable {
    let token: String
    let refreshToken: String
    let refreshTokenExpiration: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
        case refreshTokenExpiration = "refresh_token_expiration"
    }
}

struct RefreshTokenResponse: Codable {
    let token: String
    let refreshToken: String
    let refreshTokenExpiration: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case refreshToken = "refresh_token"
        case refreshTokenExpiration = "refresh_token_expiration"
    }
}

// MARK: - Request Models
struct RefreshTokenRequest: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
