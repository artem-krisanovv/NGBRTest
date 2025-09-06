import Foundation
import CoreData

// MARK: - Contractor Models
struct Contractor: Codable, Identifiable {
    let id: Int
    let fullName: String?
    let name: String
    let inn: String
    let kpp: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "fullName"
        case name
        case inn
        case kpp
    }
}

//MARK: - Request Models
struct CreateContractorRequest: Codable {
    let fullName: String?
    let name: String
    let inn: String
    let kpp: String?
}

struct UpdateContractorRequest: Codable {
    let id: Int
    let fullName: String?
    let name: String
    let inn: String
    let kpp: String?
}

// MARK: - Local Contractor Model
extension Contractor {
    func toLocalModel() -> Counterparty {
        let context = PersistenceController.shared.container.viewContext
        let local = Counterparty(context: context)
        local.id = String(self.id)
        local.name = self.name
        local.details = self.fullName
        local.inn = self.inn
        local.kpp = self.kpp
        local.updatedAt = Date()
        return local
    }
    
    static func fromLocalModel(_ local: Counterparty) -> Contractor? {
        guard let idString = local.id, let id = Int(idString), let name = local.name else { return nil }
        return Contractor(
            id: id,
            fullName: local.details,
            name: name,
            inn: local.inn ?? "",
            kpp: local.kpp
        )
    }
}
