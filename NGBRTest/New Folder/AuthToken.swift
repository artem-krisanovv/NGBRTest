import Foundation

struct AuthToken {
    let accessToken: String
    let refreshToken: String
    var expiry: Date? {
        JWTDecoder.expirationDate(from: accessToken)
    }
    var roles: [String] {
        JWTDecoder.roles(from: accessToken)
    }
}
