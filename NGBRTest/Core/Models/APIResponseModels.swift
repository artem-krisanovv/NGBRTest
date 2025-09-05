import Foundation

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
    let success: Bool
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let total: Int?
    let page: Int?
    let limit: Int?

    enum CodingKeys: String, CodingKey {
        case data
        case total
        case page
        case limit
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode([T].self, forKey: .data)
        total = try container.decodeIfPresent(Int.self, forKey: .total)
        page = try container.decodeIfPresent(Int.self, forKey: .page)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
    }
}

struct MessagesResponse: Codable {
    let messages: [String]
}

// MARK: - Empty Response
struct EmptyResponse: Codable {}
