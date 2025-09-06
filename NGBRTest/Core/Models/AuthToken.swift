import Foundation

// MARK: - Authentication Token Model
struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
    var expiry: Date? {
        JWTDecoder.expirationDate(from: accessToken)
    }
    var roles: [String] {
        JWTDecoder.roles(from: accessToken)
    }
}
