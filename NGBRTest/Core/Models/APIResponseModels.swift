import Foundation

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let success: Bool
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}
