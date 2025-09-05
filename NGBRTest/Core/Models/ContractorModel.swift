import Foundation
import CoreData

// MARK: - Contractor Models
struct Contractor: Codable, Identifiable {
    let id: String
    let name: String
    let details: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case details
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CreateContractorRequest: Codable {
    let name: String
    let details: String?
}

struct UpdateContractorRequest: Codable {
    let name: String
    let details: String?
}

// MARK: - Local Contractor Model (for Core Data)
extension Contractor {
    func toLocalModel() -> Counterparty {
        let local = Counterparty()
        local.id = self.id
        local.name = self.name
        local.details = self.details
        local.updatedAt = self.updatedAt
        return local
    }
    
    static func fromLocalModel(_ local: Counterparty) -> Contractor? {
        guard let id = local.id, let name = local.name else { return nil }
        return Contractor(
            id: id,
            name: name,
            details: local.details,
            createdAt: nil,
            updatedAt: local.updatedAt
        )
    }
}
