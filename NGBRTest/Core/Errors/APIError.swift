import Foundation

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case httpError(status: Int, data: Data?)
    case decodingError
    case unauthorized
    case accessDenied
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .httpError(let status, _):
            return "HTTP Error: \(status)"
        case .decodingError:
            return "Failed to decode response"
        case .unauthorized:
            return "Unauthorized access"
        case .accessDenied:
            return "Access denied"
        case .networkError:
            return "Network error"
        }
    }
}
