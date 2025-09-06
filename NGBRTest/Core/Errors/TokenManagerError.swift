import Foundation

// MARK: - Token Manager Errors
enum AuthError: Error, LocalizedError {
    case noRefreshToken
    case refreshFailed
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        case .refreshFailed:
            return "Failed to refresh token"
        case .unauthorized:
            return "Unauthorized"
        }
    }
}
